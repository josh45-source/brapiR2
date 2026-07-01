#' Internal: Build a BrAPI Request
#'
#' Constructs an httr2 request object with the correct base URL, path,
#' authentication headers, and timeout.
#'
#' @param con A `brapi_con` object.
#' @param endpoint Character. The API endpoint path (e.g. "/programs").
#'
#' @return An httr2 request object.
#' @keywords internal
brapi_req <- function(con, endpoint) {
  # Remove leading slash if present
  endpoint <- sub("^/", "", endpoint)

  req <- request(con$base_url) |>
    req_url_path_append("brapi", con$version, endpoint) |>
    req_headers("Accept" = "application/json") |>
    req_retry(max_tries = 3, backoff = ~2)

  if (!is.null(con$token)) {
    req <- req |> req_auth_bearer_token(con$token)
  }

  req
}


#' Internal: GET a BrAPI Endpoint with Automatic Pagination
#'
#' Sends a GET request to a BrAPI endpoint and handles pagination
#' transparently. Returns all pages concatenated into a single tibble.
#' When caching is enabled on `con` (via [brapi_cache_enable()]), the
#' full multi-page result is stored as a JSON file keyed by URL +
#' sorted query parameters. Subsequent calls within the TTL window skip
#' the HTTP request and return the cached result.
#'
#' @param con A `brapi_con` object.
#' @param endpoint Character. The API endpoint (e.g. "/programs").
#' @param query Named list. Query parameters to append to the URL.
#'
#' @return A tibble of results, or an empty tibble if no data.
#' @importFrom rlang hash
#' @keywords internal
brapi_get <- function(con, endpoint, query = list()) {
  validate_con(con)

  query$pageSize <- query$pageSize %||% con$page_size
  query$page <- 0L

  # ---- Cache lookup ----
  # The key covers the full result (all pages), so exclude the page param.
  cache_file <- NULL
  if (!is.null(con$cache)) {
    key_query <- query[setdiff(names(query), "page")]
    key_str <- paste0(
      con$base_url, "/brapi/", con$version, "/",
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
    cache_file <- file.path(
      con$cache$dir,
      paste0(rlang::hash(key_str), ".json")
    )

    if (file.exists(cache_file)) {
      age <- as.numeric(
        difftime(Sys.time(), file.mtime(cache_file), units = "secs")
      )
      if (age <= con$cache$ttl) {
        cli_alert_info("Using cached response for {.path {endpoint}}.")
        cached <- fromJSON(cache_file, simplifyVector = FALSE)
        return(parse_brapi_result(cached))
      }
    }
  }

  # ---- HTTP request (with pagination) ----
  all_data <- list()
  total_pages <- 1L
  current_page <- 0L

  repeat {
    query$page <- current_page

    resp <- brapi_req(con, endpoint) |>
      req_url_query(!!!query) |>
      req_perform()

    body <- resp_body_json(resp, simplifyVector = FALSE)

    pagination <- body$metadata$pagination
    if (!is.null(pagination)) {
      total_pages <- pagination$totalPages %||% 1L
    }

    data <- body$result$data %||% list()

    # Single-object endpoint (no `data` envelope) — return immediately,
    # no caching because there is nothing to paginate.
    if (!is.null(body$result) && is.null(body$result$data)) {
      return(parse_brapi_result(list(body$result)))
    }

    if (length(data) > 0L) {
      all_data <- c(all_data, data)
    }

    current_page <- current_page + 1L
    if (current_page >= total_pages) break
  }

  # ---- Cache write ----
  # Use auto_unbox = TRUE so R scalars serialise as JSON scalars (not 1-element
  # arrays).  R lists from simplifyVector = FALSE are never auto-unboxed, so
  # true array fields remain arrays after the round-trip.
  if (!is.null(cache_file) && length(all_data) > 0L) {
    writeLines(toJSON(all_data, auto_unbox = TRUE), cache_file)
  }

  if (length(all_data) == 0L) {
    return(tibble())
  }

  parse_brapi_result(all_data)
}


#' Internal: POST Search to a BrAPI Endpoint
#'
#' Handles the BrAPI search pattern:
#' - POST to `/search/{entity}` with a JSON body
#' - If 200: results are in the response body directly
#' - If 202: server returns a `searchResultsDbId`; poll
#'   `GET /search/{entity}/{searchResultsDbId}` until results are ready
#'
#' @param con A `brapi_con` object.
#' @param endpoint Character. The search endpoint (e.g. "/search/germplasm").
#' @param body Named list. The search request body.
#' @param poll_interval Numeric. Seconds between polling attempts. Default 2.
#' @param max_polls Integer. Maximum polling attempts before giving up. Default 30.
#'
#' @return A tibble of search results.
#' @keywords internal
brapi_post_search <- function(con, endpoint, body = list(),
                              poll_interval = 2, max_polls = 30L) {
  validate_con(con)

  body$pageSize <- body$pageSize %||% con$page_size

  # BrAPI search bodies expect filter fields as JSON arrays, even when the
  # caller supplies a single value.  Wrap every character vector with I() so
  # jsonlite does not auto-unbox ["name"] → "name" (which causes HTTP 400).
  body <- lapply(body, function(val) {
    if (is.character(val)) I(val) else val
  })

  resp <- brapi_req(con, endpoint) |>
    req_body_json(body) |>
    req_method("POST") |>
    req_perform()

  status <- resp_status(resp)
  resp_body <- resp_body_json(resp, simplifyVector = FALSE)

  if (status == 202L || !is.null(resp_body$result$searchResultsDbId)) {
    # Async search — poll for results
    search_id <- resp_body$result$searchResultsDbId %||%
      resp_body$searchResultsDbId

    if (is.null(search_id)) {
      cli_abort("Server returned 202 but no {.field searchResultsDbId}.")
    }

    cli_alert_info("Async search started (ID: {search_id}). Polling...")

    poll_endpoint <- paste0(endpoint, "/", search_id)
    for (i in seq_len(max_polls)) {
      Sys.sleep(poll_interval)

      poll_resp <- brapi_req(con, poll_endpoint) |>
        req_url_query(pageSize = con$page_size) |>
        req_perform()

      poll_status <- resp_status(poll_resp)
      if (poll_status == 200L) {
        poll_body <- resp_body_json(poll_resp, simplifyVector = FALSE)
        data <- poll_body$result$data %||% list()
        if (length(data) == 0) {
          return(tibble())
        }
        return(parse_brapi_result(data))
      }
    }

    cli_abort("Search timed out after {max_polls} attempts.")
  }

  # Immediate 200 response
  data <- resp_body$result$data %||% list()
  if (length(data) == 0) {
    return(tibble())
  }
  parse_brapi_result(data)
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
parse_brapi_result <- function(data) {
  if (length(data) == 0) {
    return(tibble())
  }

  tryCatch(
    {
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
          if (is.list(val) || length(val) > 1L) {
            return(list(val))
          }
          val
        })
        tibble::as_tibble_row(record, .name_repair = "minimal")
      })
      bind_rows(rows)
    },
    error = function(e) {
      json_text <- toJSON(data, auto_unbox = TRUE)
      as_tibble(fromJSON(json_text, flatten = TRUE))
    }
  )
}
