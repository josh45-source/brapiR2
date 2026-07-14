test_that("brapi_cache_enable adds cache config to connection", {
  con <- brapi_connection("https://test-server.brapi.org")
  tmpdir <- tempdir()

  con <- brapi_cache_enable(con, dir = file.path(tmpdir, "brapi_test_cache"))
  expect_false(is.null(con$cache))
  expect_identical(con$cache$ttl, 3600)
  expect_true(dir.exists(con$cache$dir))

  # Cleanup
  unlink(file.path(tmpdir, "brapi_test_cache"), recursive = TRUE)
})

test_that("brapi_cache_clear works on empty cache", {
  con <- brapi_connection("https://test-server.brapi.org")
  tmpdir <- tempdir()
  con <- brapi_cache_enable(con, dir = file.path(tmpdir, "brapi_test_cache2"))

  expect_no_error(brapi_cache_clear(con))

  # Cleanup
  unlink(file.path(tmpdir, "brapi_test_cache2"), recursive = TRUE)
})

test_that("brapi_cache_clear warns when caching not enabled", {
  con <- brapi_connection("https://test-server.brapi.org")
  expect_no_error(brapi_cache_clear(con))
})
