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

test_that("parse_brapi_result falls back to jsonlite flatten on bad records", {
  # A record whose element is itself a data.frame will break as_tibble_row's
  # size-1 assumption and trigger the tryCatch fallback branch.
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
