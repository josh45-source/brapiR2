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
      access_url = "https://example.org/token"
    ),
    "OAuth2 login failed"
  )
})

test_that("brapi_login_oauth2 form-encodes the client-credentials request", {
  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(
    req_perform = function(req) {
      seen$req <- req
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw('{"access_token": "oauth_tok"}')
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  con2 <- expect_no_warning(brapi_login_oauth2(
    con,
    client_id = "id",
    client_secret = "s3cret",
    access_url = "https://auth.example.org/token"
  ))

  req <- seen$req
  expect_identical(req$url, "https://auth.example.org/token")
  expect_identical(req$method, "POST")
  expect_identical(req$body$type, "form")
  expect_identical(
    unlist(req$body$data),
    c(grant_type = "client_credentials", client_id = "id",
      client_secret = "s3cret")
  )
  expect_identical(con2$token, "oauth_tok")
})

test_that("brapi_login_oauth2 warns that authorize_url is deprecated", {
  local_mocked_bindings(
    req_perform = function(req) {
      expect_identical(req$url, "https://auth.example.org/token")
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw('{"access_token": "oauth_tok"}')
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_warning(
    con2 <- brapi_login_oauth2(
      con, "id", "s3cret",
      "https://auth.example.org/authorize",
      "https://auth.example.org/token"
    ),
    "authorize_url"
  )
  expect_identical(con2$token, "oauth_tok")
})

test_that("brapi_login honours the connection path and sends a user agent", {
  captured <- new.env()
  local_mocked_bindings(
    req_perform = function(req) {
      captured$url <- req$url
      captured$ua <- req$headers[["User-Agent"]]
      structure(list(), class = "httr2_response")
    },
    resp_body_json = function(resp, ...) list(access_token = "tok"),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org", path = "gringlobal/brapi")
  out <- brapi_login(con, "u", "p")

  expect_identical(out$token, "tok")
  expect_match(captured$url, "/gringlobal/brapi/v2/token", fixed = TRUE)
  expect_match(captured$ua, "^brapiR2/")
})

test_that("brapi_login reports the server's reason when no token comes back", {
  # Breedbase answers a bad password with HTTP 200, a null token and the
  # reason in metadata.status.
  seen <- new.env(parent = emptyenv())
  local_mocked_bindings(
    req_perform = function(req) {
      seen$req <- req
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(paste0(
          '{"metadata": {"status": [{"messageType": "ERROR",',
          ' "message": "Incorrect Password"}]},',
          ' "access_token": null}'
        ))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  err <- expect_error(brapi_login(con, "user", "wrong"), "Login failed")
  expect_match(conditionMessage(err), "Incorrect Password")
  expect_identical(seen$req$url, "https://example.org/brapi/v2/token")
  expect_identical(seen$req$body$data$username, "user")
})
