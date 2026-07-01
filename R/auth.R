#' Login to a BrAPI Server with Username and Password
#'
#' Authenticates using the BrAPI `/token` endpoint and returns an updated
#' connection object with the Bearer token set.
#'
#' @param con A [brapi_connection()] object.
#' @param username Character. Your username.
#' @param password Character. Your password.
#'
#' @return A new `brapi_con` object with the token populated.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://my-breedbase.org")
#' con <- brapi_login(con, "my_user", "my_password")
#' }
#'
#' @export
brapi_login <- function(con, username, password) {
  validate_con(con)

  body <- list(
    username = username,
    password = password,
    grant_type = "password"
  )

  resp <- request(con$base_url) |>
    req_url_path_append("brapi", con$version, "token") |>
    req_body_json(body) |>
    req_method("POST") |>
    req_retry(max_tries = 3) |>
    req_perform()

  result <- resp_body_json(resp)

  token <- result$access_token %||%
    result$result$access_token %||%
    result$metadata$token

  if (is.null(token)) {
    cli_abort("Login failed: no access token returned by the server.")
  }

  con$token <- token
  cli_alert_success("Logged in to {.url {con$base_url}}")
  con
}


#' Login to a BrAPI Server with OAuth 2.0
#'
#' Performs an OAuth 2.0 authorization code flow or client credentials flow.
#' Returns an updated connection object with the Bearer token set.
#'
#' @param con A [brapi_connection()] object.
#' @param client_id Character. OAuth client ID.
#' @param client_secret Character. OAuth client secret.
#' @param authorize_url Character. The authorization endpoint URL.
#' @param access_url Character. The token endpoint URL.
#'
#' @return A new `brapi_con` object with the token populated.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://ebs.example.org")
#' con <- brapi_login_oauth2(
#'   con,
#'   client_id = "my_client_id",
#'   client_secret = "my_secret",
#'   authorize_url = "https://auth.example.org/oauth2/authorize",
#'   access_url = "https://auth.example.org/oauth2/token"
#' )
#' }
#'
#' @export
brapi_login_oauth2 <- function(con, client_id, client_secret,
                               authorize_url, access_url) {
  validate_con(con)

  # Client credentials grant (non-interactive)
  body <- list(
    grant_type    = "client_credentials",
    client_id     = client_id,
    client_secret = client_secret
  )

  resp <- request(access_url) |>
    req_body_json(body) |>
    req_method("POST") |>
    req_retry(max_tries = 3) |>
    req_perform()

  result <- resp_body_json(resp)

  token <- result$access_token
  if (is.null(token)) {
    cli_abort("OAuth2 login failed: no access token returned.")
  }

  con$token <- token
  cli_alert_success("Authenticated via OAuth2 to {.url {con$base_url}}")
  con
}


#' Manually Set an Authentication Token
#'
#' If you already have a token (e.g. from a web browser session), you can
#' set it directly without going through a login flow.
#'
#' @param con A [brapi_connection()] object.
#' @param token Character. The Bearer token string.
#'
#' @return A new `brapi_con` object with the token populated.
#'
#' @examples
#' con <- brapi_connection("https://test-server.brapi.org")
#' con <- brapi_set_token(con, "my_existing_token")
#'
#' @export
brapi_set_token <- function(con, token) {
  validate_con(con)
  if (!is.character(token) || length(token) != 1) {
    cli_abort("{.arg token} must be a single character string.")
  }
  con$token <- token
  con
}
