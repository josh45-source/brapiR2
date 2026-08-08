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

  writeLines("{}", file.path(tmpdir, "a.json"))
  writeLines("{}", file.path(tmpdir, "b.json"))
  expect_length(list.files(tmpdir), 2L)

  brapi_cache_clear(con)
  expect_length(list.files(tmpdir), 0L)
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
