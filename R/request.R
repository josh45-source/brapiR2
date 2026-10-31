#' Internal: Build a BrAPI Request
#'
#' Constructs an httr2 request object with the correct base URL, path,
#' authentication headers, and timeout.
#'
#' @inheritParams brapi_shared_params
#' @param endpoint Character. The API endpoint path (e.g. "/programs").
#'
#' @return An httr2 request object.
#' @keywords internal
#' @noRd
brapi_req <- function(con, endpoint) {
  # Remove leading slash if present
  endpoint <- sub("^/", "", endpoint)

  req <- request(con$base_url) |>
    req_url_path_append(con$path %||% "brapi", con$version, endpoint) |>
    req_headers(
      "Accept" = "application/json",
      "User-Agent" = con$user_agent %||% brapi_user_agent()
    ) |>
    req_retry(max_tries = 3, backoff = ~2) |>
    req_timeout(con$timeout %||% 120) |>
    # Errors are raised by the caller instead, so the server's own
    # message can be read out of the response body first.
    req_error(is_error = function(resp) FALSE)

  if (!is.null(con$token)) {
    req <- req |> req_auth_bearer_token(con$token)
  }

  req
}


#' Call Any BrAPI GET Endpoint
#'
#' The named functions in brapiR2 cover 32 of the 37 BrAPI v2.1 entities.
#' This is the layer beneath them, for endpoints brapiR2 does not wrap, for
#' servers with non-standard extensions, and for query parameters a named
#' function does not expose. Pagination, caching, authentication and error
#' reporting work exactly as they do for the named functions.
#'
#' @section Return shape:
#' The response passes through the same parser the named functions use, so
#' a well-formed BrAPI collection returns one row per record. An endpoint
#' returning something the parser does not recognise may come back with
#' list-columns or a shape you need to reshape yourself. The named
#' functions are the better choice wherever one exists.
#'
#' @inheritParams brapi_shared_params
#' @param endpoint Character. The endpoint path, with or without a leading
#'   slash (for example `"/programs"` or `"commoncropnames"`). The base
#'   URL, BrAPI path and version come from `con`.
#' @param query Named list. Query parameters to append to the URL.
#'   `pageSize` defaults to the connection's page size; `page` is managed
#'   by the pagination loop and should not be set here.
#' @param max_pages Numeric. Stop after this many pages instead of
#'   fetching all of them. `Inf`, the default, fetches everything. A
#'   production server may hold hundreds of thousands of records, so a
#'   small value is useful for looking at what an unfamiliar server holds.
#'   A truncated result is never cached.
#'
#' @return A tibble of results, or an empty tibble if the endpoint
#'   returned no data.
#'
#' @seealso [brapi_post_search()] for the POST search endpoints.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'
#'   # An endpoint brapiR2 does not wrap
#'   brapi_get(con, "/commoncropnames")
#'
#'   # A query parameter no named function exposes
#'   brapi_get(con, "/studies", query = list(active = "true"))
#' }
#' }
#'
#' @importFrom rlang hash
#' @export
brapi_get <- function(con, endpoint, query = list(), max_pages = Inf) {
  validate_con(con)
  ok_max_pages <- is.numeric(max_pages) && length(max_pages) == 1L &&
    !is.na(max_pages) && max_pages >= 1 &&
    (is.infinite(max_pages) || max_pages == round(max_pages))
  if (!ok_max_pages) {
    cli_abort(
      "{.arg max_pages} must be a whole number of at least 1, or {.code Inf}."
    )
  }

  # A NULL filter means "not set". A GET filter takes one value; several
  # are what the POST search functions are for.
  query <- query[!vapply(query, is.null, logical(1))]
  multi <- names(query)[lengths(query) > 1L]
  if (length(multi)) {
    cli_abort(c(
      "Query parameter{?s} {.arg {multi}} must be a single value.",
      "i" = paste(
        "To filter on several values, use the matching",
        "{.code brapi_search_*()} function, or {.fn brapi_fetch_parallel}",
        "to make one call per value."
      )
    ))
  }
  query <- brapi_query_values(query)

  query$pageSize <- query$pageSize %||% con$page_size
  query$page <- 0L

  cache_file <- brapi_cache_path(con, endpoint, query)
  if (!is.null(cache_file)) {
    cached <- brapi_cache_read(cache_file, con$cache$ttl, endpoint)
    if (!is.null(cached)) {
      return(cached)
    }
  }

  pages <- brapi_get_pages(con, endpoint, query, max_pages)
  if (pages$single) {
    return(parse_brapi_result(pages$data))
  }

  all_data <- pages$data

  # A truncated result must never be cached: a later call would read it
  # back as if it were the whole set.
  cacheable <- !is.null(cache_file) && length(all_data) > 0L &&
    pages$complete
  if (cacheable) {
    brapi_cache_write(all_data, cache_file)
  }

  if (length(all_data) == 0L) {
    return(tibble())
  }

  parse_brapi_result(all_data)
}


#' Internal: Build the Cache File Path for a Request
#'
#' Returns `NULL` if caching is not enabled on `con`. Otherwise builds a
#' deterministic cache key from the URL and sorted query parameters
#' (excluding `page`, since the key covers the full multi-page result),
#' plus a hash of the connection's token, so that responses fetched with
#' one set of credentials are never served to a connection with another.
#'
#' @inheritParams brapi_shared_params
#' @param endpoint Character. The API endpoint.
#' @param query Named list. Query parameters.
#'
#' @return A file path, or `NULL` if caching is not enabled.
#' @keywords internal
#' @noRd
brapi_cache_path <- function(con, endpoint, query) {
  if (is.null(con$cache)) {
    return(NULL)
  }

  key_query <- query[setdiff(names(query), "page")]
  key_str <- paste0(
    con$base_url, "/", con$path %||% "brapi", "/", con$version, "/",
    sub("^/", "", endpoint)
  )
  if (length(key_query) > 0L) {
    q <- key_query[order(names(key_query))]
    key_str <- paste0(
      key_str, "?",
      paste0(names(q), "=", vapply(q, as.character, character(1L)),
        collapse = "&"
      )
    )
  }
  if (!is.null(con$token)) {
    key_str <- paste0(key_str, "#token:", rlang::hash(con$token))
  }
  file.path(con$cache$dir, paste0(rlang::hash(key_str), ".json"))
}


#' Internal: Serialise Records to JSON Without Losing Precision
#'
#' Use auto_unbox = TRUE so R scalars serialise as JSON scalars (not
#' 1-element arrays). R lists from simplifyVector = FALSE are never
#' auto-unboxed, so true array fields remain arrays after the round-trip.
#' `digits = NA` keeps full precision (jsonlite otherwise rounds to four
#' decimal places), and `always_decimal = TRUE` keeps a double such as 2.0
#' from coming back as an integer.
#'
#' @param data A list of records.
#'
#' @return A JSON string.
#' @keywords internal
#' @noRd
brapi_to_json <- function(data) {
  toJSON(data, auto_unbox = TRUE, digits = NA, always_decimal = TRUE)
}


#' Internal: Write Records to the Cache
#'
#' Writes to a temporary file in the cache directory and renames it into
#' place, so a reader never sees a half-written entry.
#'
#' @param data A list of records.
#' @param cache_file Character. The cache entry's path.
#'
#' @return Invisibly `NULL`; called for its side effect.
#' @keywords internal
#' @noRd
brapi_cache_write <- function(data, cache_file) {
  tmp <- tempfile("brapi_cache_", tmpdir = dirname(cache_file))
  writeLines(brapi_to_json(data), tmp)
  if (!file.rename(tmp, cache_file)) {
    unlink(tmp)
  }
  invisible(NULL)
}


#' Internal: Read a Cached Response if Still Fresh
#'
#' @param cache_file Character. Path to the cache file.
#' @param ttl Numeric. Time-to-live in seconds.
#' @param endpoint Character. The API endpoint (used in the status message).
#'
#' @return A parsed tibble, or `NULL` if there is no fresh cache entry.
#' @keywords internal
#' @noRd
brapi_cache_read <- function(cache_file, ttl, endpoint) {
  if (!file.exists(cache_file)) {
    return(NULL)
  }
  age <- as.numeric(
    difftime(Sys.time(), file.mtime(cache_file), units = "secs")
  )
  if (age > ttl) {
    return(NULL)
  }
  cli_alert_info("Using cached response for {.path {endpoint}}.")
  cached <- fromJSON(cache_file, simplifyVector = FALSE)
  parse_brapi_result(cached)
}


#' Internal: Fetch All Pages of a GET Endpoint
#'
#' @inheritParams brapi_shared_params
#' @param endpoint Character. The API endpoint.
#' @param query Named list. Query parameters (the `page` element is
#'   overwritten on each iteration).
#'
#' @return A list with elements `data` (the accumulated records, or a
#'   single result object when `single` is `TRUE`) and `single` (logical;
#'   `TRUE` for single-object endpoints with no `data` envelope).
#' @keywords internal
#' @noRd
brapi_get_pages <- function(con, endpoint, query, max_pages = Inf) {
  all_data <- list()
  total_pages <- 1L
  current_page <- 0L
  complete <- TRUE
  prev_data <- NULL
  prev_reported <- NULL

  repeat {
    query$page <- current_page

    resp <- brapi_req(con, endpoint) |>
      req_url_query(!!!query) |>
      req_perform()

    brapi_stop_for_status(resp, con, endpoint)

    body <- resp_body_json(resp, simplifyVector = FALSE)

    pagination <- body$metadata$pagination
    total_pages <- brapi_total_pages(pagination)

    data <- body$result$data %||% list()

    # Single-object endpoint (no `data` envelope) — return immediately,
    # no caching because there is nothing to paginate.
    # A collection endpoint's `data` is a list of record objects. A
    # single-object endpoint may itself carry a field called `data`
    # (`/lists/{listDbId}` holds its members there, as bare strings), so
    # treat `data` as the record envelope when it holds objects, or when
    # it is the only field in `result` (`/commoncropnames` returns a bare
    # list of crop names that way).
    is_envelope <- !is.null(body$result$data) &&
      (length(data) == 0L ||
        all(vapply(data, is.list, logical(1))) ||
        identical(names(body$result), "data"))
    if (!is.null(body$result) && !is_envelope) {
      return(list(data = list(body$result), single = TRUE, complete = TRUE))
    }

    # A server that ignores `page` serves the same page again: the same
    # reported currentPage, or the same records. Keep what is already in
    # hand rather than duplicating it on every remaining page.
    reported <- pagination$currentPage
    if (current_page > 0L &&
          ((!is.null(reported) && identical(reported, prev_reported)) ||
             (length(data) > 0L && identical(data, prev_data)))) {
      cli_warn(c(
        "The server seems to ignore {.field page} on {.field {endpoint}}.",
        "i" = "Page {current_page} repeated the previous page; keeping the
          {length(all_data)} record{?s} already fetched."
      ))
      complete <- FALSE
      break
    }
    prev_reported <- reported
    prev_data <- data

    if (length(data) > 0L) {
      all_data <- c(all_data, data)
    }

    current_page <- current_page + 1L
    if (current_page >= total_pages) break
    if (current_page >= max_pages) {
      cli_alert_info(paste(
        "Stopped after {current_page} page{?s};",
        "the server reports {total_pages}."
      ))
      complete <- FALSE
      break
    }
  }

  list(data = all_data, single = FALSE, complete = complete)
}


#' Internal: Encode Query Values the Way BrAPI Servers Expect
#'
#' httr2 writes a logical as `TRUE`/`FALSE`; the specification's examples,
#' and servers that compare the string, use `true`/`false`.
#'
#' @param query Named list of query parameters.
#'
#' @return `query`, with logical values as lowercase strings.
#' @keywords internal
#' @noRd
brapi_query_values <- function(query) {
  lapply(query, function(val) {
    if (is.logical(val)) tolower(as.character(val)) else val
  })
}


#' Internal: Number of Pages a Paginated Response Reports
#'
#' Uses `totalPages` when the server gives it, and otherwise derives it from
#' `totalCount` and `pageSize`, which some servers send without it.
#'
#' @param pagination The `metadata$pagination` element of a response.
#'
#' @return The number of pages, or 1 if the response doesn't say.
#' @keywords internal
#' @noRd
brapi_total_pages <- function(pagination) {
  if (!is.null(pagination$totalPages)) {
    return(pagination$totalPages)
  }
  count <- pagination$totalCount
  size <- pagination$pageSize
  if (!is.null(count) && !is.null(size) && size > 0) {
    return(as.integer(ceiling(count / size)))
  }
  1L
}


#' Call Any BrAPI Search Endpoint
#'
#' The companion to [brapi_get()] for the POST `/search/{entity}`
#' endpoints, which take a filter body rather than query parameters and
#' may run asynchronously. Use it for search endpoints brapiR2 does not
#' wrap, or for filter fields a named search function does not expose.
#'
#' @section Asynchronous searches:
#' A server may answer immediately with the results, or with HTTP 202 and
#' a `searchResultsDbId` to be polled until the results are ready. Both
#' are handled here; the polling happens inside the call and you get the
#' finished results either way. Results spanning several pages are fetched
#' page by page and returned together.
#'
#' @section Return shape:
#' As with [brapi_get()], the response passes through the same parser the
#' named functions use. A well-formed BrAPI result returns one row per
#' record; an unusual one may need reshaping yourself.
#'
#' @inheritParams brapi_shared_params
#' @param endpoint Character. The search endpoint, with or without a
#'   leading slash (for example `"/search/germplasm"`).
#' @param body Named list. The search request body. Filter fields are sent
#'   as JSON arrays, as BrAPI expects, even when you supply a single value.
#' @param poll_interval Numeric. Seconds between polling attempts for an
#'   asynchronous search. Default 2.
#' @param max_polls Integer. Maximum polling attempts before giving up.
#'   Default 30.
#'
#' @return A tibble of search results.
#'
#' @seealso [brapi_get()] for the GET endpoints.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_post_search(con, "/search/germplasm",
#'                     body = list(germplasmNames = "Tomatillo Fantastico"))
#' }
#' }
#'
#' @export
brapi_post_search <- function(con, endpoint, body = list(),
                              poll_interval = 2, max_polls = 30L) {
  validate_con(con)

  body$pageSize <- body$pageSize %||% con$page_size

  # BrAPI search filters are JSON arrays, even when the caller supplies a
  # single value, so wrap them with I() to stop jsonlite auto-unboxing
  # ["name"] to "name" (which causes HTTP 400). Array filters have plural
  # names (germplasmDbIds); the deprecated studyDbId is the one exception.
  # Other string fields (sepUnphased, sortBy, ...) are scalars.
  body <- Map(function(val, name) {
    is_array <- grepl("s$", name) || name == "studyDbId"
    if (is.character(val) && is_array) I(val) else val
  }, body, names(body))

  # Later pages of an immediate result are requested by re-posting the
  # same body with `page` set. `[[` rather than `$`, which would partially
  # match `page` to `pageSize`.
  post_page <- function(page) {
    if (page > 0L) body[["page"]] <- page
    resp <- brapi_req(con, endpoint) |>
      req_body_json(body) |>
      req_method("POST") |>
      req_perform()
    brapi_stop_for_status(resp, con, endpoint)
    resp
  }

  resp <- post_page(0L)
  status <- resp_status(resp)
  resp_body <- resp_body_json(resp, simplifyVector = FALSE)

  if (status == 202L || !is.null(resp_body$result$searchResultsDbId)) {
    search_id <- resp_body$result$searchResultsDbId %||%
      resp_body$searchResultsDbId

    if (is.null(search_id)) {
      cli_abort("Server returned 202 but no {.field searchResultsDbId}.")
    }

    return(brapi_poll_search(
      con, endpoint, search_id, poll_interval, max_polls,
      page_size = body[["pageSize"]]
    ))
  }

  # Immediate 200 response
  data <- collect_search_pages(resp_body, function(page) {
    resp_body_json(post_page(page), simplifyVector = FALSE)
  })
  if (length(data) == 0) {
    return(tibble())
  }
  parse_brapi_result(data)
}


#' Internal: Gather the Records From Every Page of a Search Result
#'
#' @param first_body The parsed body of the first page.
#' @param fetch_page A function taking a zero-based page number and
#'   returning that page's parsed body.
#'
#' @return A list of records from all pages, in page order.
#' @keywords internal
#' @noRd
collect_search_pages <- function(first_body, fetch_page) {
  data <- first_body$result$data %||% list()
  total_pages <- brapi_total_pages(first_body$metadata$pagination)
  page <- 1L
  while (page < total_pages) {
    page_body <- fetch_page(page)
    data <- c(data, page_body$result$data %||% list())
    page <- page + 1L
  }
  data
}


#' Internal: Poll an Async BrAPI Search Until Results Are Ready
#'
#' @inheritParams brapi_shared_params
#' @param endpoint Character. The original search endpoint.
#' @param search_id Character. The `searchResultsDbId` from the initial POST.
#' @param poll_interval Numeric. Seconds between polling attempts.
#' @param max_polls Integer. Maximum polling attempts before giving up.
#' @param page_size Integer. Records per page of the finished result.
#'
#' @return A tibble of search results, from every page.
#' @keywords internal
#' @noRd
brapi_poll_search <- function(con, endpoint, search_id,
                              poll_interval, max_polls,
                              page_size = con$page_size) {
  cli_alert_info("Async search started (ID: {search_id}). Polling...")

  poll_endpoint <- paste0(endpoint, "/", search_id)
  get_page <- function(page) {
    resp <- brapi_req(con, poll_endpoint) |>
      req_url_query(page = page, pageSize = page_size) |>
      req_perform()
    brapi_stop_for_status(resp, con, poll_endpoint)
    resp
  }

  for (i in seq_len(max_polls)) {
    Sys.sleep(poll_interval)

    poll_resp <- get_page(0L)

    poll_status <- resp_status(poll_resp)
    if (poll_status == 200L) {
      poll_body <- resp_body_json(poll_resp, simplifyVector = FALSE)
      data <- collect_search_pages(poll_body, function(page) {
        resp_body_json(get_page(page), simplifyVector = FALSE)
      })
      if (length(data) == 0) {
        return(tibble())
      }
      return(parse_brapi_result(data))
    }
  }

  cli_abort("Search timed out after {max_polls} attempts.")
}


#' Internal: Parse BrAPI Result List into a Tibble
#'
#' Takes a list of result objects (each a named list) and flattens
#' them into a tibble. Nested lists are kept as list-columns.
#'
#' @param data A list of named lists (one per record).
#'
#' @return A tibble.
#' @keywords internal
#' @noRd
parse_brapi_result <- function(data) {
  if (length(data) == 0) {
    return(tibble())
  }

  # A collection of bare values rather than objects (`/commoncropnames`
  # returns its crop names that way) is one `value` column.
  if (!any(vapply(data, is.list, logical(1)))) {
    return(tibble(value = unlist(data, use.names = FALSE)))
  }

  rows <- map(data, function(record) {
    record <- map(record, function(val) {
      if (is.null(val)) {
        return(NA)
      }
      if (is.list(val) && length(val) == 0) {
        return(NA)
      }
      # Wrap lists and multi-element vectors as list-columns so
      # as_tibble_row (which requires size-1 elements) doesn't error.
      # Named lists have their keys sorted first: JSON object key order
      # is not significant, and some servers vary it between records,
      # which would otherwise make identical records compare as distinct.
      if (is.list(val) || length(val) > 1L) {
        if (is.list(val) && !is.null(names(val))) {
          val <- val[order(names(val))]
        }
        return(list(val))
      }
      val
    })
    tibble::as_tibble_row(record, .name_repair = "minimal")
  })
  bind_rows(unify_column_types(rows))
}


#' Internal: Make a Column's Type Agree Across Records
#'
#' A field can arrive as a different JSON type in different records, such
#' as a plot number that is `1` in one and `"2A"` in another, or a value that
#' is a string in one and an array in another. `bind_rows()` cannot combine
#' those, so before binding, a column holding a list in any record becomes a
#' list-column in every record, and a column holding a string alongside
#' other scalar types becomes character. Numbers and logicals combine
#' without help, and a missing value (`NA`) fits any type.
#'
#' @param rows A list of tibbles: one row per record, or (from
#'   [brapi_fetch_parallel()]) one per call.
#'
#' @return `rows`, with conflicting columns made consistent.
#' @keywords internal
#' @noRd
unify_column_types <- function(rows) {
  col_type <- function(col) {
    if (is.list(col)) {
      "list"
    } else if (is.logical(col) && all(is.na(col))) {
      NA_character_
    } else {
      typeof(col)
    }
  }
  types <- list()
  for (row in rows) {
    for (nm in names(row)) {
      types[[nm]] <- union(types[[nm]], col_type(row[[nm]]))
    }
  }
  types <- lapply(types, function(t) t[!is.na(t)])

  to_list <- names(types)[vapply(types, function(t) {
    "list" %in% t && length(t) > 1L
  }, logical(1))]
  to_chr <- names(types)[vapply(types, function(t) {
    !"list" %in% t && "character" %in% t && length(t) > 1L
  }, logical(1))]
  if (length(to_list) == 0L && length(to_chr) == 0L) {
    return(rows)
  }

  lapply(rows, function(row) {
    for (nm in intersect(to_list, names(row))) {
      if (!is.list(row[[nm]])) row[[nm]] <- as.list(row[[nm]])
    }
    for (nm in intersect(to_chr, names(row))) {
      row[[nm]] <- as.character(row[[nm]])
    }
    row
  })
}
