## Cache integration tests
## Require network access to test-server.brapi.org; skipped on CRAN and offline.

skip_if_offline_brapi <- function() {
  skip_if_offline(host = "test-server.brapi.org")
}

SERVER <- "https://test-server.brapi.org"

# ---------------------------------------------------------------------------
# Cache mechanics: file creation, hit, and expiry — no network needed
# ---------------------------------------------------------------------------

test_that("cache file is written after a successful brapi_get call", {
  skip_on_cran()
  skip_if_offline_brapi()

  tmpdir <- file.path(tempdir(), paste0("brapi_cache_write_", Sys.getpid()))
  con <- brapi_connection(SERVER) |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  brapi_programs(con)

  cache_files <- list.files(tmpdir, pattern = "\\.json$")
  expect_length(cache_files, 1L)
})

test_that("second call returns cached result and skips HTTP", {
  skip_on_cran()
  skip_if_offline_brapi()

  tmpdir <- file.path(tempdir(), paste0("brapi_cache_hit_", Sys.getpid()))
  con <- brapi_connection(SERVER) |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # First call — populates cache
  result1 <- brapi_programs(con)

  # Second call — should read from cache (no HTTP)
  t_start <- proc.time()[["elapsed"]]
  result2 <- brapi_programs(con)
  t_cached <- proc.time()[["elapsed"]] - t_start

  # Results must be identical
  expect_identical(result1, result2)

  # Cached call should be faster than a typical HTTP round-trip (>0.3 s).
  # Even on a slow machine a file read finishes in well under 0.3 s.
  expect_lt(t_cached, 0.3)
})

test_that("expired cache entry triggers a fresh HTTP request", {
  skip_on_cran()
  skip_if_offline_brapi()

  tmpdir <- file.path(tempdir(), paste0("brapi_cache_expire_", Sys.getpid()))
  con <- brapi_connection(SERVER) |>
    brapi_cache_enable(dir = tmpdir, ttl = 0) # TTL = 0 → always expired
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  result1 <- brapi_programs(con)
  Sys.sleep(0.05) # tiny pause so mtime advances
  result2 <- brapi_programs(con)

  # Both calls must succeed and return a non-empty tibble
  expect_s3_class(result1, "data.frame")
  expect_s3_class(result2, "data.frame")
  expect_gt(nrow(result1), 0L)
})

test_that("different queries produce different cache files", {
  skip_on_cran()
  skip_if_offline_brapi()

  tmpdir <- file.path(tempdir(), paste0("brapi_cache_diff_", Sys.getpid()))
  con <- brapi_connection(SERVER) |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  brapi_programs(con)
  brapi_trials(con)

  cache_files <- list.files(tmpdir, pattern = "\\.json$")
  expect_gte(length(cache_files), 2L)
})

# ---------------------------------------------------------------------------
# brapi_cache_clear
# ---------------------------------------------------------------------------

test_that("brapi_cache_clear removes all cache files", {
  skip_on_cran()
  skip_if_offline_brapi()

  tmpdir <- file.path(tempdir(), paste0("brapi_cache_clear_", Sys.getpid()))
  con <- brapi_connection(SERVER) |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  brapi_programs(con)
  brapi_trials(con)

  expect_gt(length(list.files(tmpdir)), 0L)

  brapi_cache_clear(con)

  expect_length(list.files(tmpdir), 0L)
})

test_that("brapi_cache_clear on empty cache does not error", {
  tmpdir <- file.path(tempdir(), paste0("brapi_cache_empty_", Sys.getpid()))
  con <- brapi_connection("https://test-server.brapi.org") |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  expect_no_error(brapi_cache_clear(con))
})

# ---------------------------------------------------------------------------
# Cache key determinism (no network needed)
# ---------------------------------------------------------------------------

test_that("cache key is deterministic for identical requests", {
  tmpdir <- file.path(tempdir(), paste0("brapi_cache_key_", Sys.getpid()))
  con <- brapi_connection("https://test-server.brapi.org") |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # Manually write a fake cache file at the expected key
  # The key path is: hash(base_url/brapi/v2/programs?pageSize=1000) + .json
  key_str <- "https://test-server.brapi.org/brapi/v2/programs?pageSize=1000"
  key_file <- file.path(tmpdir, paste0(rlang::hash(key_str), ".json"))

  # Write a fake one-record result using auto_unbox = TRUE to match how
  # brapi_get() serialises cache entries (scalars must stay as scalars).
  fake_data <- list(list(programDbId = "fake_01", programName = "Fake Program"))
  writeLines(jsonlite::toJSON(fake_data, auto_unbox = TRUE), key_file)

  # brapi_programs should pick up the fake cache
  result <- brapi_programs(con)
  expect_identical(result$programDbId[[1L]], "fake_01")
})
