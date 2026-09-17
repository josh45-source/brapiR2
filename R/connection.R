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
#' @param path Character. URL path segment before the version, for servers
#'   that do not serve BrAPI at `/brapi/`. Default `"brapi"`. GRIN-Global
#'   instances, for example, use `"gringlobal/brapi"`.
#' @param user_agent Character or NULL. Overrides the user agent brapiR2
#'   sends with each request. The default identifies the package, its
#'   version, and the httr2 and R versions in use.
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
#' # Connect to a server that serves BrAPI under a different path
#' con <- brapi_connection("https://npgsweb.ars-grin.gov",
#'                         path = "gringlobal/brapi")
#'
#' @export
brapi_connection <- function(url,
                             token = NULL,
                             version = "v2",
                             path = "brapi",
                             user_agent = NULL,
                             page_size = 1000L,
                             timeout = 120) {
  # Validate inputs
  if (!is.character(url) || length(url) != 1 || nchar(url) == 0) {
    cli_abort("{.arg url} must be a single non-empty character string.")
  }

  if (!is.character(path) || length(path) != 1 || nchar(path) == 0) {
    cli_abort("{.arg path} must be a single non-empty character string.")
  }
  path <- gsub("^/+|/+$", "", path)

  if (!is.null(user_agent) &&
      (!is.character(user_agent) || length(user_agent) != 1 ||
       nchar(user_agent) == 0)) {
    cli_abort(
      "{.arg user_agent} must be NULL or a single non-empty character string."
    )
  }

  # Clean URL: remove trailing slashes

  url <- sub("/+$", "", url)

  structure(
    list(
      base_url   = url,
      token      = token,
      version    = version,
      path       = path,
      user_agent = user_agent,
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
  # auth_status/cache_status are used below via cli's glue-style string
  # interpolation ("{auth_status}"), which lintr's static analysis can't see.
  auth_status <- if (!is.null(x$token)) { # nolint: object_usage_linter.
    cli::col_green("\u2713 authenticated")
  } else {
    cli::col_yellow("\u2717 no token")
  }
  cache_status <- if (!is.null(x$cache)) { # nolint: object_usage_linter.
    glue("enabled ({x$cache$dir})")
  } else {
    "disabled"
  }

  cli::cli_h3("BrAPI Connection")
  bullets <- c(
    "Server:    {.url {x$base_url}}",
    "Version:   {x$version}"
  )
  if ((x$path %||% "brapi") != "brapi") {
    bullets <- c(bullets, "Path:      {x$path}")
  }
  bullets <- c(
    bullets,
    "Auth:      {auth_status}",
    "Page size: {x$page_size}",
    "Timeout:   {x$timeout}s",
    "Cache:     {cache_status}"
  )
  cli::cli_ul(bullets)
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
