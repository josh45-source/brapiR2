## Mocked tests for brapi_get()/brapi_post_search() internals — no network
## required. These patch httr2's req_perform(), resp_status(), and
## resp_body_json() bindings inside brapiR2's namespace.

test_that("brapi_get paginates across multiple pages", {
  call_n <- new.env()
  call_n$n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      resp <- structure(list(page = call_n$n), class = "httr2_response")
      call_n$n <- call_n$n + 1
      resp
    },
    resp_body_json = function(resp, ...) {
      id <- if (resp$page == 0L) "a" else "b"
      list(
        metadata = list(pagination = list(totalPages = 2L)),
        result = list(data = list(list(id = id)))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_get(con, "/programs")

  expect_identical(nrow(result), 2L)
  expect_identical(sort(result$id), c("a", "b"))
})

test_that("brapi_get returns an empty tibble when there is no data", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(data = list())
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_get(con, "/programs")

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 0L)
})

test_that("brapi_get handles single-object endpoints with no data envelope", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(metadata = list(), result = list(foo = "bar"))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_get(con, "/serverinfo")

  expect_identical(result$foo, "bar")
})

test_that("brapi_get uses cache on second call within TTL", {
  tmpdir <- file.path(tempdir(), paste0("brapi_get_cache_", Sys.getpid()))
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  call_count <- new.env()
  call_count$n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_count$n <- call_count$n + 1
      structure(list(), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) {
      list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(data = list(list(id = "x")))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)

  r1 <- brapi_get(con, "/programs")
  r2 <- brapi_get(con, "/programs")

  expect_identical(call_count$n, 1)
  expect_identical(r1, r2)
})

test_that("brapi_get refetches when the cache entry has expired", {
  tmpdir <- file.path(tempdir(), paste0("brapi_get_cache_exp_", Sys.getpid()))
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  call_count <- new.env()
  call_count$n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_count$n <- call_count$n + 1
      structure(list(), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) {
      list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(data = list(list(id = "x")))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir, ttl = 0)

  brapi_get(con, "/programs")
  Sys.sleep(0.05)
  brapi_get(con, "/programs")

  expect_identical(call_count$n, 2)
})

test_that("a cached response returns the same values as a fresh one", {
  tmpdir <- tempfile("brapi_cache_precision_")
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  local_mocked_bindings(
    req_perform = function(req) {
      q <- httr2::url_parse(req$url)$query
      expect_match(req$url, "/brapi/v2/locations\\?")
      expect_identical(q[["page"]], "0")
      expect_identical(q[["pageSize"]], "1000")
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(paste0(
          '{"metadata": {"pagination": {"totalPages": 1}},',
          ' "result": {"data": [{"locationDbId": "L1",',
          ' "latitude": 12.3456789, "altitude": 2.0, "plots": 3}]}}'
        ))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir)
  fresh <- brapi_get(con, "/locations")
  cached <- suppressMessages(brapi_get(con, "/locations"))

  expect_identical(fresh$latitude, 12.3456789)
  expect_identical(cached, fresh)
  # Written via a temporary file and renamed: nothing else is left behind.
  expect_identical(list.files(tmpdir), basename(
    brapi_cache_path(con, "/locations", list(pageSize = 1000L, page = 0L))
  ))
})

test_that("a column that changes type keeps full numeric precision", {
  data <- list(
    list(plotNumber = 1L, latitude = 0.123456789),
    list(plotNumber = "2A", latitude = 1.5)
  )
  res <- parse_brapi_result(data)
  expect_identical(res$latitude, c(0.123456789, 1.5))
})

test_that("a type conflict between records doesn't change the columns", {
  consistent <- list(
    list(id = "1", geo = list(type = "Point")),
    list(id = "2", geo = list(type = "Point"))
  )
  conflicting <- list(
    list(id = 1L, geo = list(type = "Point")),
    list(id = "2A", geo = list(type = "Point"))
  )

  expected_names <- names(parse_brapi_result(consistent))
  res <- parse_brapi_result(conflicting)

  expect_identical(names(res), expected_names)
  expect_identical(res$id, c("1", "2A"))
  expect_true(is.list(res$geo))
  expect_identical(res$geo[[2]], list(type = "Point"))
})

test_that("a field that is a list in any record becomes a list-column", {
  data <- list(
    list(id = "a", synonyms = "x"),
    list(id = "b", synonyms = list("y", "z"))
  )
  res <- parse_brapi_result(data)

  expect_true(is.list(res$synonyms))
  expect_identical(res$synonyms[[1]], "x")
  expect_identical(res$synonyms[[2]], list("y", "z"))
})

test_that("brapi_get returns the same columns when types differ across pages", {
  local_mocked_bindings(
    req_perform = function(req) {
      q <- httr2::url_parse(req$url)$query
      expect_match(req$url, "/brapi/v2/observationunits\\?")
      expect_identical(q[["pageSize"]], "1000")
      page <- as.integer(q[["page"]])
      unit <- list(
        observationUnitDbId = paste0("u", page),
        plotNumber = if (page == 0L) 1L else "2A",
        position = list(positionCoordinateX = "1")
      )
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(jsonlite::toJSON(list(
          metadata = list(pagination = list(currentPage = page,
                                            totalPages = 2L)),
          result = list(data = list(unit))
        ), auto_unbox = TRUE))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  res <- brapi_get(con, "/observationunits")

  expect_identical(
    names(res), c("observationUnitDbId", "plotNumber", "position")
  )
  expect_identical(res$plotNumber, c("1", "2A"))
})

test_that("brapi_post_search returns data on an immediate 200 response", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_status = function(resp) 200L,
    resp_body_json = function(resp, ...) {
      list(result = list(data = list(list(id = "x"))))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_post_search(
    con, "/search/germplasm",
    body = list(germplasmNames = "x")
  )

  expect_identical(result$id, "x")
})

test_that("brapi_post_search returns an empty tibble on 200 with no data", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_status = function(resp) 200L,
    resp_body_json = function(resp, ...) list(result = list(data = list())),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_post_search(con, "/search/germplasm", body = list())

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 0L)
})

test_that("brapi_post_search polls an async search until results ready", {
  call_n <- new.env()
  call_n$n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_n$n <- call_n$n + 1
      structure(list(call = call_n$n), class = "httr2_response")
    },
    resp_status = function(resp) if (resp$call == 1L) 202L else 200L,
    resp_body_json = function(resp, ...) {
      if (resp$call == 1L) {
        list(result = list(searchResultsDbId = "sr123"))
      } else {
        list(result = list(data = list(list(id = "y"))))
      }
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_post_search(
    con, "/search/germplasm",
    body = list(), poll_interval = 0
  )

  expect_identical(result$id, "y")
})

test_that("brapi_post_search returns empty tibble when polling finds no data", {
  call_n <- new.env()
  call_n$n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_n$n <- call_n$n + 1
      structure(list(call = call_n$n), class = "httr2_response")
    },
    resp_status = function(resp) if (resp$call == 1L) 202L else 200L,
    resp_body_json = function(resp, ...) {
      if (resp$call == 1L) {
        list(result = list(searchResultsDbId = "sr123"))
      } else {
        list(result = list(data = list()))
      }
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_post_search(
    con, "/search/germplasm",
    body = list(), poll_interval = 0
  )

  expect_identical(nrow(result), 0L)
})

test_that("brapi_post_search errors when 202 response has no search id", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_status = function(resp) 202L,
    resp_body_json = function(resp, ...) list(result = list()),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(
    brapi_post_search(con, "/search/germplasm", body = list()),
    "searchResultsDbId"
  )
})

test_that("brapi_post_search errors after max_polls without completing", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_status = function(resp) 202L,
    resp_body_json = function(resp, ...) {
      list(result = list(searchResultsDbId = "sr123"))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(
    brapi_post_search(con, "/search/germplasm", body = list(),
      poll_interval = 0, max_polls = 2L
    ),
    "timed out"
  )
})

## A search with 6 matching records served 2 per page (3 pages). `page`
## picks the records for one page; anything not on a real page is empty.
search_page_body <- function(page) {
  ids <- if (page %in% 0:2) paste0("g", 2L * page + 1:2) else character()
  list(
    metadata = list(pagination = list(
      currentPage = page, pageSize = 2L, totalCount = 6L, totalPages = 3L
    )),
    result = list(data = lapply(ids, function(id) list(germplasmDbId = id)))
  )
}

json_response <- function(body, status = 200L) {
  httr2::response(
    status_code = status,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(jsonlite::toJSON(body, auto_unbox = TRUE))
  )
}

test_that("brapi_post_search fetches every page of an immediate result", {
  seen <- new.env(parent = emptyenv())
  seen$bodies <- list()
  local_mocked_bindings(
    req_perform = function(req) {
      expect_identical(req$method, "POST")
      expect_match(req$url, "/brapi/v2/search/germplasm$")
      body <- req$body$data
      seen$bodies[[length(seen$bodies) + 1L]] <- body
      json_response(search_page_body(body[["page"]] %||% 0L))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org", page_size = 2L)
  result <- brapi_post_search(
    con, "/search/germplasm",
    body = list(germplasmNames = "x")
  )

  expect_identical(result$germplasmDbId, paste0("g", 1:6))
  expect_length(seen$bodies, 3L)
  pages <- vapply(seen$bodies, function(b) b[["page"]] %||% 0L, numeric(1))
  expect_identical(pages, c(0, 1, 2))
  for (b in seen$bodies) {
    expect_identical(b[["pageSize"]], 2L)
    expect_identical(unclass(b[["germplasmNames"]]), "x")
  }
})

test_that("brapi_post_search fetches every page of an async result", {
  seen <- new.env(parent = emptyenv())
  seen$gets <- list()
  local_mocked_bindings(
    req_perform = function(req) {
      if (identical(req$method, "POST")) {
        return(json_response(
          list(result = list(searchResultsDbId = "sr123")), 202L
        ))
      }
      expect_match(req$url, "/brapi/v2/search/germplasm/sr123\\?")
      q <- httr2::url_parse(req$url)$query
      seen$gets[[length(seen$gets) + 1L]] <- q
      json_response(search_page_body(as.integer(q[["page"]] %||% 0L)))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org", page_size = 2L)
  result <- suppressMessages(brapi_post_search(
    con, "/search/germplasm",
    body = list(), poll_interval = 0
  ))

  expect_identical(result$germplasmDbId, paste0("g", 1:6))
  pages <- vapply(seen$gets, function(q) q[["page"]] %||% "0", character(1))
  expect_identical(pages, c("0", "1", "2"))
  for (q in seen$gets) expect_identical(q[["pageSize"]], "2")
})

test_that("parse_brapi_result keeps a data.frame element as a list-column", {
  bad_data <- list(list(id = "1", nested = data.frame(x = 1:2)))
  result <- parse_brapi_result(bad_data)

  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 1L)
  expect_identical(result$id, "1")
  expect_identical(result$nested[[1]]$x, 1:2)
})

test_that("brapi_req builds the default /brapi/ path", {
  captured <- new.env()
  local_mocked_bindings(
    req_perform = function(req) {
      captured$url <- req$url
      structure(list(), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) {
      list(metadata = list(pagination = list(totalPages = 1L)),
           result = list(data = list()))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  brapi_get(con, "/serverinfo")
  expect_match(captured$url, "/brapi/v2/serverinfo?pageSize", fixed = TRUE)
})

test_that("brapi_req honours a custom path", {
  captured <- new.env()
  local_mocked_bindings(
    req_perform = function(req) {
      captured$url <- req$url
      structure(list(), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) {
      list(metadata = list(pagination = list(totalPages = 1L)),
           result = list(data = list()))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org", path = "gringlobal/brapi")
  brapi_get(con, "/serverinfo")
  expect_match(captured$url, "/gringlobal/brapi/v2/serverinfo?pageSize",
               fixed = TRUE)
})

test_that("brapi_cache_path keys differ for the same host on different paths", {
  dir <- file.path(tempdir(), paste0("path_key_", Sys.getpid()))
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)

  a <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = dir)
  b <- brapi_connection("https://example.org", path = "gringlobal/brapi") |>
    brapi_cache_enable(dir = dir)

  expect_false(identical(
    brapi_cache_path(a, "/programs", list()),
    brapi_cache_path(b, "/programs", list())
  ))
})

test_that("parse_brapi_result normalises key order in nested objects", {
  a <- list(list(id = "1", season = list(seasonDbId = "2026", year = "2026")))
  b <- list(list(id = "1", season = list(year = "2026", seasonDbId = "2026")))

  ra <- brapiR2:::parse_brapi_result(a)
  rb <- brapiR2:::parse_brapi_result(b)

  # Same record, different JSON key order: the rows must compare as identical.
  expect_identical(ra$season, rb$season)
  expect_identical(nrow(unique(rbind(ra, rb))), 1L)
})

test_that("brapi_req sends a user agent, and a custom one when given", {
  captured <- new.env()
  local_mocked_bindings(
    req_perform = function(req) {
      captured$ua <- req$headers[["User-Agent"]]
      structure(list(), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) {
      list(metadata = list(pagination = list(totalPages = 1L)),
           result = list(data = list()))
    },
    .package = "brapiR2"
  )

  brapi_get(brapi_connection("https://example.org"), "/serverinfo")
  expect_match(captured$ua, "^brapiR2/")

  con <- brapi_connection("https://example.org", user_agent = "mine/1.0")
  brapi_get(con, "/serverinfo")
  expect_identical(captured$ua, "mine/1.0")
})

test_that("brapi_connection rejects an invalid user agent", {
  expect_error(
    brapi_connection("https://example.org", user_agent = ""),
    "non-empty"
  )
  expect_error(
    brapi_connection("https://example.org", user_agent = 123),
    "character"
  )
})

test_that("a result field named data is not mistaken for the record envelope", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(
          listDbId = "list1",
          listName = "Example",
          data = list("germ1", "germ2")
        )
      )
    },
    .package = "brapiR2"
  )

  out <- brapi_get(brapi_connection("https://example.org"), "/lists/list1")
  expect_identical(nrow(out), 1L)
  expect_true(all(c("listDbId", "listName", "data") %in% names(out)))
})

test_that("brapi_server_message reads the spec status envelope", {
  resp <- httr2::response_json(
    status_code = 401,
    body = list(metadata = list(status = list(
      list(messageType = "INFO", message = "loading"),
      list(messageType = "ERROR", message = "You must login.")
    )))
  )
  expect_identical(brapiR2:::brapi_server_message(resp), "You must login.")
})

test_that("brapi_server_message reads a bare Message field", {
  resp <- httr2::response_json(status_code = 404,
                               body = list(Message = "Not found."))
  expect_identical(brapiR2:::brapi_server_message(resp), "Not found.")
})

test_that("brapi_server_message ignores an HTML error page", {
  resp <- httr2::response(status_code = 500,
                          headers = list(`content-type` = "text/html"),
                          body = charToRaw("<html>oops</html>"))
  expect_null(brapiR2:::brapi_server_message(resp))
})

test_that("a result holding only data is a collection, even of scalars", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(data = list("Tomatillo", "Paw Paw", "Maize"))
      )
    },
    .package = "brapiR2"
  )

  out <- brapi_get(brapi_connection("https://example.org"), "/commoncropnames")
  expect_identical(nrow(out), 3L)
})

test_that("max_pages stops the pagination loop early", {
  page <- 0L
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      page <<- page + 1L
      list(
        metadata = list(pagination = list(totalPages = 10L)),
        result = list(data = list(list(id = as.character(page))))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  out <- suppressMessages(brapi_get(con, "/studies", max_pages = 2))
  expect_identical(nrow(out), 2L)
  expect_identical(page, 2L)
})

test_that("a truncated result is not cached", {
  dir <- file.path(tempdir(), paste0("trunc_", Sys.getpid()))
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)

  local_mocked_bindings(
    req_perform = function(req) {
      page <- httr2::url_parse(req$url)$query[["page"]]
      structure(list(page = page), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) {
      list(
        metadata = list(pagination = list(totalPages = 5L)),
        result = list(data = list(list(id = resp$page)))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = dir)
  suppressMessages(brapi_get(con, "/studies", max_pages = 1))
  expect_length(list.files(dir), 0L)

  suppressMessages(brapi_get(con, "/studies"))
  expect_length(list.files(dir), 1L)
})

## A /programs server holding 6 records, 2 per page. `pagination` builds
## the metadata for a requested page; `honour_page = FALSE` makes the
## server serve page 0 whatever was asked for. Records each query.
mock_paged_server <- function(pagination, honour_page = TRUE) {
  seen <- new.env(parent = emptyenv())
  seen$queries <- list()
  respond <- function(req) {
    expect_match(req$url, "/brapi/v2/programs\\?")
    q <- httr2::url_parse(req$url)$query
    seen$queries[[length(seen$queries) + 1L]] <- q
    asked <- as.integer(q[["page"]])
    served <- if (honour_page) asked else 0L
    ids <- paste0("p", 2L * served + 1:2)
    body <- list(
      metadata = list(pagination = pagination(served)),
      result = list(data = lapply(ids, function(id) list(programDbId = id)))
    )
    httr2::response(
      status_code = 200L,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw(jsonlite::toJSON(body, auto_unbox = TRUE))
    )
  }
  list(respond = respond, queries = function() seen$queries)
}

test_that("brapi_get derives the page count from totalCount", {
  server <- mock_paged_server(function(page) {
    list(currentPage = page, pageSize = 2L, totalCount = 6L)
  })
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org", page_size = 2L)
  res <- brapi_get(con, "/programs")

  expect_identical(res$programDbId, paste0("p", 1:6))
  pages <- vapply(server$queries(), function(q) q[["page"]], character(1))
  expect_identical(pages, c("0", "1", "2"))
  for (q in server$queries()) expect_identical(q[["pageSize"]], "2")
})

test_that("brapi_get stops when a server ignores page", {
  server <- mock_paged_server(
    function(page) list(currentPage = page, pageSize = 2L, totalPages = 3L),
    honour_page = FALSE
  )
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  dir <- withr::local_tempdir()
  con <- brapi_connection("https://example.org", page_size = 2L) |>
    brapi_cache_enable(dir = dir)
  expect_warning(res <- brapi_get(con, "/programs"), "ignore")

  expect_identical(res$programDbId, c("p1", "p2"))
  pages <- vapply(server$queries(), function(q) q[["page"]], character(1))
  expect_identical(pages, c("0", "1"))
  # An incomplete result is never cached.
  expect_length(list.files(dir), 0L)
})

test_that("brapi_get stops on a repeated page without currentPage", {
  server <- mock_paged_server(
    function(page) list(pageSize = 2L, totalPages = 3L),
    honour_page = FALSE
  )
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org", page_size = 2L)
  expect_warning(res <- brapi_get(con, "/programs"), "ignore")
  expect_identical(res$programDbId, c("p1", "p2"))
})

test_that("brapi_get validates max_pages", {
  con <- brapi_connection("https://example.org")
  for (bad in list(NA, 0, -1, 1.5, "2", c(1, 2), NULL)) {
    expect_error(brapi_get(con, "/programs", max_pages = bad), "max_pages")
  }
})

test_that("brapi_post_search derives the page count from totalCount", {
  local_mocked_bindings(
    req_perform = function(req) {
      expect_match(req$url, "/brapi/v2/search/programs$")
      page <- req$body$data[["page"]] %||% 0L
      expect_identical(req$body$data[["pageSize"]], 2L)
      ids <- paste0("p", 2L * page + 1:2)
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(jsonlite::toJSON(list(
          metadata = list(pagination = list(
            currentPage = page, pageSize = 2L, totalCount = 6L
          )),
          result = list(data = lapply(ids, function(id) {
            list(programDbId = id)
          }))
        ), auto_unbox = TRUE))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org", page_size = 2L)
  res <- brapi_post_search(con, "/search/programs")
  expect_identical(res$programDbId, paste0("p", 1:6))
})
