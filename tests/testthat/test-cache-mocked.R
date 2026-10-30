## Mocked tests for cache.R paths that don't need network: default cache
## dir, clearing populated files, and parallel fetching.

test_that("brapi_cache_enable uses a rappdirs default dir when unspecified", {
  con <- brapi_connection("https://example.org")
  con2 <- brapi_cache_enable(con)
  on.exit(unlink(con2$cache$dir, recursive = TRUE), add = TRUE)

  expect_true(grepl("brapiR2", con2$cache$dir, fixed = TRUE))
  expect_true(dir.exists(con2$cache$dir))
})

test_that("brapi_cache_clear removes populated cache files", {
  tmpdir <- file.path(tempdir(), paste0("brapi_cache_manual_", Sys.getpid()))
  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  writeLines("{}", brapi_cache_path(con, "/programs", list()))
  writeLines("{}", brapi_cache_path(con, "/trials", list()))
  expect_length(list.files(tmpdir), 2L)

  brapi_cache_clear(con)
  expect_length(list.files(tmpdir), 0L)
})

test_that("brapi_cache_clear leaves files that aren't cache entries", {
  tmpdir <- tempfile("brapi_cache_shared_")
  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  entry <- brapi_cache_path(con, "/programs", list())
  writeLines("{}", entry)
  writeLines("x <- 1", file.path(tmpdir, "my-analysis.R"))
  writeLines("{}", file.path(tmpdir, "results.json"))
  dir.create(file.path(tmpdir, "subdir"))

  brapi_cache_clear(con)

  expect_setequal(
    list.files(tmpdir),
    c("my-analysis.R", "results.json", "subdir")
  )
})

## The bearer token a request carries, or NULL. httr2 >= 1.1.0 redacts the
## Authorization header in `req$headers`, so read it back with
## req_get_headers(); DESCRIPTION still allows httr2 1.0.0, which lacks it.
request_token <- function(req) {
  headers <- if (utils::packageVersion("httr2") >= "1.1.0") {
    httr2::req_get_headers(req, "reveal")
  } else {
    req$headers
  }
  auth <- headers$Authorization
  if (is.null(auth)) NULL else sub("^Bearer ", "", auth)
}

test_that("cache entries are not shared between different tokens", {
  tmpdir <- tempfile("brapi_cache_tokens_")
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  local_mocked_bindings(
    req_perform = function(req) {
      q <- httr2::url_parse(req$url)$query
      expect_match(req$url, "/brapi/v2/programs\\?")
      expect_identical(q[["page"]], "0")
      expect_identical(q[["pageSize"]], "1000")
      id <- request_token(req) %||% "public"
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(paste0(
          '{"metadata": {"pagination": {"totalPages": 1}},',
          ' "result": {"data": [{"programDbId": "', id, '"}]}}'
        ))
      )
    },
    .package = "brapiR2"
  )

  base <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir)
  alice <- brapi_set_token(base, "alice-token")
  bob <- brapi_set_token(base, "bob-token")

  expect_identical(brapi_get(alice, "/programs")$programDbId, "alice-token")
  expect_identical(brapi_get(base, "/programs")$programDbId, "public")
  expect_identical(brapi_get(bob, "/programs")$programDbId, "bob-token")
  # Each identity's entry is still served from the cache afterwards.
  expect_message(
    alice_again <- brapi_get(alice, "/programs"),
    "cached"
  )
  expect_identical(alice_again$programDbId, "alice-token")
  # The token never appears in the cache file names.
  expect_false(any(grepl("token", list.files(tmpdir))))
})

test_that("brapi_fetch_parallel calls future_map_dfr() and combines results", {
  # brapi_fetch_parallel() no longer sets a future::plan() itself - it uses
  # whatever plan is already active (sequential, absent a caller-set one),
  # so there is nothing to mock on the future side any more. Mocking
  # furrr::future_map_dfr() still avoids actually spinning up workers.
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")

  called <- new.env()
  called$n <- 0L
  local_mocked_bindings(
    future_map_dfr = function(.x, .f, ...) {
      called$n <- called$n + 1L
      purrr::map_dfr(.x, .f)
    },
    .package = "furrr"
  )

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)
  result <- brapi_fetch_parallel(con, fn, c("a", "b"))

  expect_identical(called$n, 1L)
  expect_identical(result$id, c("a", "b"))
})

test_that("brapi_fetch_parallel warns and continues when .fn errors", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_mocked_bindings(
    future_map_dfr = function(.x, .f, ...) purrr::map_dfr(.x, .f),
    .package = "furrr"
  )

  con <- brapi_connection("https://example.org")
  bad_fn <- function(con, id) {
    if (identical(id, "bad")) stop("boom")
    tibble::tibble(id = id)
  }

  expect_warning(
    result <- brapi_fetch_parallel(con, bad_fn, c("good", "bad")),
    "Failed for ID"
  )
  expect_identical(result$id, "good")
})

test_that("brapi_fetch_parallel warns that .workers is deprecated", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_mocked_bindings(
    future_map_dfr = function(.x, .f, ...) purrr::map_dfr(.x, .f),
    .package = "furrr"
  )

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)

  expect_warning(
    result <- brapi_fetch_parallel(con, fn, c("a", "b"), .workers = 2),
    "deprecated"
  )
  expect_identical(result$id, c("a", "b"))
})

test_that("brapi_fetch_parallel does not warn when .workers is omitted", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_mocked_bindings(
    future_map_dfr = function(.x, .f, ...) purrr::map_dfr(.x, .f),
    .package = "furrr"
  )

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)

  expect_no_warning(brapi_fetch_parallel(con, fn, c("a", "b")))
})
