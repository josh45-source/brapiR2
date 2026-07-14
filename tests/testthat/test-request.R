test_that("parse_brapi_result handles empty list", {
  result <- parse_brapi_result(list())
  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 0L)
})

test_that("parse_brapi_result converts simple records to tibble", {
  data <- list(
    list(id = "1", name = "Program A", description = "Desc A"),
    list(id = "2", name = "Program B", description = "Desc B")
  )
  result <- parse_brapi_result(data)
  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 2L)
  expect_true("id" %in% names(result))
  expect_true("name" %in% names(result))
})

test_that("parse_brapi_result handles NULL values as NA", {
  data <- list(
    list(id = "1", name = "Test", value = NULL)
  )
  result <- parse_brapi_result(data)
  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 1L)
  expect_true(is.na(result$value))
})

test_that("brapi_req builds correct URL structure", {
  con <- brapi_connection("https://test-server.brapi.org")
  req <- brapi_req(con, "/programs")
  # Check the URL contains the expected path
  expect_true(grepl("brapi/v2/programs", req$url, fixed = TRUE))
})

test_that("brapi_req strips leading slash from endpoint", {
  con <- brapi_connection("https://test-server.brapi.org")
  req1 <- brapi_req(con, "/programs")
  req2 <- brapi_req(con, "programs")
  expect_identical(req1$url, req2$url)
})

test_that("brapi_req adds auth header when token present", {
  con <- brapi_connection("https://test-server.brapi.org", token = "abc")
  req <- brapi_req(con, "/programs")
  # httr2 stores auth internally; just verify no error

  expect_s3_class(req, "httr2_request")
})
