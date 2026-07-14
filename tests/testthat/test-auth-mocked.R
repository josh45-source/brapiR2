## Mocked auth tests — no network required. These patch httr2's req_perform()
## and resp_body_json() bindings inside brapiR2's namespace so brapi_login()
## and brapi_login_oauth2() run their full real logic against a fake response.

test_that("brapi_login stores the access_token from a successful response", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) list(access_token = "tok_abc"),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  con2 <- brapi_login(con, "user", "pass")

  expect_identical(con2$token, "tok_abc")
})

test_that("brapi_login falls back to result$access_token and metadata$token", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(result = list(access_token = "tok_nested"))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  con2 <- brapi_login(con, "user", "pass")
  expect_identical(con2$token, "tok_nested")

  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(metadata = list(token = "tok_meta"))
    },
    .package = "brapiR2"
  )
  con3 <- brapi_login(con, "user", "pass")
  expect_identical(con3$token, "tok_meta")
})

test_that("brapi_login errors when no access token is returned", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) list(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(brapi_login(con, "user", "pass"), "no access token")
})

test_that("brapi_login_oauth2 stores the access_token via client credentials", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) list(access_token = "oauth_tok"),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  con2 <- brapi_login_oauth2(
    con,
    client_id = "id",
    client_secret = "secret",
    authorize_url = "https://example.org/authorize",
    access_url = "https://example.org/token"
  )

  expect_identical(con2$token, "oauth_tok")
})

test_that("brapi_login_oauth2 errors when no access token is returned", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) list(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(
    brapi_login_oauth2(
      con,
      client_id = "id",
      client_secret = "secret",
      authorize_url = "https://example.org/authorize",
      access_url = "https://example.org/token"
    ),
    "OAuth2 login failed"
  )
})
