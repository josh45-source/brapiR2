# ---- Utility Functions ----


#' Ping a BrAPI Server
#'
#' Tests whether the BrAPI server is reachable and responding.
#'
#' @inheritParams brapi_shared_params
#'
#' @return Logical. `TRUE` if the server responds, `FALSE` otherwise.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_ping(con)
#' }
#'
#' @export
brapi_ping <- function(con) {
  validate_con(con)
  tryCatch(
    {
      resp <- brapi_req(con, "/serverinfo") |>
        req_perform()
      status <- resp_status(resp)
      if (status == 200L) {
        cli_alert_success("Server {.url {con$base_url}} is reachable.")
        return(invisible(TRUE))
      }
      cli_alert_warning("Server returned status {status}.")
      invisible(FALSE)
    },
    error = function(e) {
      cli_alert_warning("Cannot reach {.url {con$base_url}}: {e$message}")
      invisible(FALSE)
    }
  )
}


#' List Available Endpoints
#'
#' Queries the `/serverinfo` endpoint to list which BrAPI calls the
#' server supports, along with their HTTP methods and versions.
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with columns for endpoint service, method(s), and
#'   version(s).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_endpoints(con)
#' }
#'
#' @export
brapi_endpoints <- function(con) {
  brapi_server_info(con)
}


#' Internal: Default User Agent String
#'
#' Identifies brapiR2 to the server, as recommended by the rOpenSci
#' packaging guidelines. The package version and URL are read from
#' DESCRIPTION so they cannot drift, and requests made on continuous
#' integration are marked as such.
#'
#' @return A single string.
#' @keywords internal
#' @noRd
brapi_user_agent <- function() {
  ua <- sprintf(
    "brapiR2/%s (https://github.com/josh45-source/brapiR2) httr2/%s R/%s",
    utils::packageVersion("brapiR2"),
    utils::packageVersion("httr2"),
    getRversion()
  )
  if (nzchar(Sys.getenv("CI"))) {
    ua <- paste0(ua, " (CI)")
  }
  ua
}
