## The live-server guard in helper-live-server.R: skip only when the ping
## was not a successful JSON response, and say why.

test_that("skip_if_brapi_down does not skip after a successful ping", {
  expect_invisible(skip_if_brapi_down(structure(TRUE, status = 200L)))
})

test_that("skip_if_brapi_down names the HTTP status in the skip message", {
  expect_condition(
    skip_if_brapi_down(structure(FALSE, status = 502L)),
    "HTTP 502 from /serverinfo",
    class = "skip"
  )
})

test_that("skip_if_brapi_down skips a server that wants authentication", {
  # brapi_ping() counts a 401 as reachable, but the live tests need data.
  expect_condition(
    skip_if_brapi_down(structure(TRUE, status = 401L)),
    "HTTP 401 from /serverinfo",
    class = "skip"
  )
})

test_that("skip_if_brapi_down reports a missing response", {
  expect_condition(
    skip_if_brapi_down(structure(FALSE, status = NA_integer_)),
    "no response from /serverinfo",
    class = "skip"
  )
})
