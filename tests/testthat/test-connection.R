test_that("brapi_connection creates a valid object", {
  con <- brapi_connection("https://test-server.brapi.org")

  expect_s3_class(con, "brapi_con")
  expect_equal(con$base_url, "https://test-server.brapi.org")
  expect_equal(con$version, "v2")
  expect_null(con$token)
  expect_equal(con$page_size, 1000L)
  expect_equal(con$timeout, 120)
  expect_null(con$cache)
})

test_that("brapi_connection removes trailing slashes", {
  con <- brapi_connection("https://test-server.brapi.org///")
  expect_equal(con$base_url, "https://test-server.brapi.org")
})

test_that("brapi_connection stores token when provided", {
  con <- brapi_connection("https://example.org", token = "abc123")
  expect_equal(con$token, "abc123")
})

test_that("brapi_connection rejects invalid URL", {
  expect_error(brapi_connection(""), "non-empty")
  expect_error(brapi_connection(123), "character")
  expect_error(brapi_connection(c("a", "b")), "single")
})

test_that("is_brapi_con works", {
  con <- brapi_connection("https://test-server.brapi.org")
  expect_true(is_brapi_con(con))
  expect_false(is_brapi_con(list()))
  expect_false(is_brapi_con("not a connection"))
})

test_that("validate_con rejects non-connection objects", {
  expect_error(validate_con("not a con"), "brapi_con")
  expect_error(validate_con(42), "brapi_con")
})

test_that("brapi_set_token updates the token", {
  con <- brapi_connection("https://test-server.brapi.org")
  con <- brapi_set_token(con, "my_token")
  expect_equal(con$token, "my_token")
})

test_that("print.brapi_con doesn't error", {
  con <- brapi_connection("https://test-server.brapi.org")
  expect_no_error(print(con))
})
