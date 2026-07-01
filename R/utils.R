# ---- Utility Functions ----


#' Ping a BrAPI Server
#'
#' Tests whether the BrAPI server is reachable and responding.
#'
#' @param con A [brapi_connection()] object.
#'
#' @return Logical. `TRUE` if the server responds, `FALSE` otherwise.
#'
#' @examples
#' \dontrun{
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
#' @param con A [brapi_connection()] object.
#'
#' @return A tibble with columns for endpoint service, method(s), and version(s).
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_endpoints(con)
#' }
#'
#' @export
brapi_endpoints <- function(con) {
  brapi_server_info(con)
}
