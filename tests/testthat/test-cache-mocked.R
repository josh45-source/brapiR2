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

test_that("brapi_fetch_parallel maps over ids and combines results", {
  local_mocked_bindings(
    plan = function(...) invisible(NULL),
    .package = "future"
  )
  local_mocked_bindings(
    future_map_dfr = function(.x, .f, ...) purrr::map_dfr(.x, .f),
    .package = "furrr"
  )

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)
  result <- brapi_fetch_parallel(con, fn, c("a", "b"))

  expect_identical(result$id, c("a", "b"))
})

test_that("brapi_fetch_parallel warns and continues when .fn errors", {
  local_mocked_bindings(
    plan = function(...) invisible(NULL),
    .package = "future"
  )
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
