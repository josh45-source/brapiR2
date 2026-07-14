## Mocked tests for brapi_get()/brapi_post_search() internals — no network
## required. These patch httr2's req_perform(), resp_status(), and
## resp_body_json() bindings inside brapiR2's namespace.

test_that("brapi_get paginates across multiple pages", {
  call_n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      resp <- structure(list(page = call_n), class = "httr2_response")
      call_n <<- call_n + 1
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

  call_count <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_count <<- call_count + 1
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

  expect_identical(call_count, 1)
  expect_identical(r1, r2)
})

test_that("brapi_get refetches when the cache entry has expired", {
  tmpdir <- file.path(tempdir(), paste0("brapi_get_cache_exp_", Sys.getpid()))
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  call_count <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_count <<- call_count + 1
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

  expect_identical(call_count, 2)
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
  call_n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_n <<- call_n + 1
      structure(list(call = call_n), class = "httr2_response")
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
  call_n <- 0
  local_mocked_bindings(
    req_perform = function(req) {
      call_n <<- call_n + 1
      structure(list(call = call_n), class = "httr2_response")
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
})
