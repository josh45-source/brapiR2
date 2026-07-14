#' Create a BrAPI Connection Object
#'
#' Creates a connection object that holds server URL, authentication token,
#' and configuration. This object is passed as the first argument to all
#' `brapiR2` functions. No global state is used.
#'
#' @param url Character. Base URL of the BrAPI server
#'   (e.g. `"https://test-server.brapi.org"`). Trailing slashes are removed.
#' @param token Character or NULL. An existing Bearer token for authentication.
#'   If NULL, you can authenticate later with [brapi_login()] or
#'   [brapi_login_oauth2()].
#' @param version Character. BrAPI version path segment. Default `"v2"`.
#' @param page_size Integer. Number of records per page for paginated requests.
#'   Default 1000.
#' @param timeout Numeric. Request timeout in seconds. Default 120.
#'
#' @return An S3 object of class `"brapi_con"` (a named list).
#'
#' @examples
#' # Connect to the public BrAPI test server (no auth needed)
#' con <- brapi_connection("https://test-server.brapi.org")
#' con
#'
#' # Connect with an existing token
#' con <- brapi_connection("https://my-breedbase.org", token = "my_token_here")
#'
#' @export
brapi_connection <- function(url,
                             token = NULL,
                             version = "v2",
                             page_size = 1000L,
                             timeout = 120) {
  # Validate inputs
  if (!is.character(url) || length(url) != 1 || nchar(url) == 0) {
    cli_abort("{.arg url} must be a single non-empty character string.")
  }

  # Clean URL: remove trailing slashes

  url <- sub("/+$", "", url)

  structure(
    list(
      base_url   = url,
      token      = token,
      version    = version,
      page_size  = as.integer(page_size),
      timeout    = timeout,
      cache      = NULL # populated by brapi_cache_enable()
    ),
    class = "brapi_con"
  )
}


#' Print a BrAPI Connection Object
#'
#' @param x A `brapi_con` object.
#' @param ... Additional arguments (ignored).
#'
#' @return Invisibly returns `x`.
#'
#' @examples
#' con <- brapi_connection("https://test-server.brapi.org")
#' print(con)
#'
#' @export
print.brapi_con <- function(x, ...) {
  auth_status <- if (!is.null(x$token)) {
    cli::col_green("\u2713 authenticated")
  } else {
    cli::col_yellow("\u2717 no token")
  }
  cache_status <- if (!is.null(x$cache)) {
    glue("enabled ({x$cache$dir})")
  } else {
    "disabled"
  }

  cli::cli_h3("BrAPI Connection")
  cli::cli_ul(c(
    "Server:    {.url {x$base_url}}",
    "Version:   {x$version}",
    "Auth:      {auth_status}",
    "Page size: {x$page_size}",
    "Timeout:   {x$timeout}s",
    "Cache:     {cache_status}"
  ))
  invisible(x)
}


#' Test if an Object is a BrAPI Connection
#'
#' @param x An object to test.
#' @return Logical.
#'
#' @examples
#' con <- brapi_connection("https://test-server.brapi.org")
#' is_brapi_con(con)
#' is_brapi_con("not a connection")
#'
#' @keywords internal
#' @export
is_brapi_con <- function(x) {
  inherits(x, "brapi_con")
}


#' Validate a Connection Object
#'
#' Checks that the input is a valid `brapi_con`. Used internally at the
#' start of every exported function.
#'
#' @param con Object to validate.
#' @return Invisibly returns `con` if valid; throws an error otherwise.
#' @noRd
validate_con <- function(con) {
  if (!is_brapi_con(con)) {
    cli_abort(c(
      "{.arg con} must be a {.cls brapi_con} object.",
      "i" = "Create one with {.fn brapi_connection}."
    ))
  }
  invisible(con)
}
