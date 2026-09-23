# ---- Utility Functions ----


#' Ping a BrAPI Server
#'
#' Tests whether the BrAPI server is reachable and responding.
#'
#' @inheritParams brapi_shared_params
#'
#' @return Logical. `TRUE` if the server responds, `FALSE` otherwise.
#'
#' @section BrAPI endpoint:
#' `GET /serverinfo` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/ServerInfo/ServerInfo_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `contentType`, `dataType`.
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
#' @section BrAPI endpoint:
#' `GET /serverinfo` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/ServerInfo/ServerInfo_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `contentType`, `dataType`.
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
    "brapiR2/%s (https://github.com/ropensci/brapiR2) httr2/%s R/%s",
    utils::packageVersion("brapiR2"),
    utils::packageVersion("httr2"),
    getRversion()
  )
  if (nzchar(Sys.getenv("CI"))) {
    ua <- paste0(ua, " (CI)")
  }
  ua
}


#' Internal: Extract a Server-Supplied Error Message
#'
#' BrAPI servers report problems in several different ways. The
#' specification puts them in `metadata.status[]` with a `messageType` of
#' `ERROR`, and Breedbase servers do this for authentication failures
#' (including on HTTP 200, where a bad password returns a null token).
#' Others return a bare JSON object with a `Message` field, or a plain
#' text sentence. Some return an HTML error page, which is never worth
#' showing a user, and some return nothing at all.
#'
#' @param resp An httr2 response.
#'
#' @return A character vector of messages, or NULL if none can be found.
#' @keywords internal
#' @noRd
brapi_server_message <- function(resp) {
  ctype <- tryCatch(resp_content_type(resp), error = function(e) NA_character_)
  if (isTRUE(grepl("html", ctype, fixed = TRUE))) {
    return(NULL)
  }

  body <- tryCatch(
    resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) NULL
  )

  if (!is.null(body)) {
    status <- body$metadata$status
    if (length(status)) {
      msgs <- vapply(
        status,
        function(s) {
          if (identical(s$messageType, "ERROR")) {
            s$message %||% NA_character_
          } else {
            NA_character_
          }
        },
        character(1)
      )
      msgs <- msgs[!is.na(msgs)]
      if (length(msgs)) {
        return(msgs)
      }
    }
    for (field in c("Message", "message", "error")) {
      if (is.character(body[[field]]) && nzchar(body[[field]])) {
        return(body[[field]])
      }
    }
    return(NULL)
  }

  txt <- tryCatch(resp_body_string(resp), error = function(e) "")
  txt <- trimws(gsub('^"|"$', "", txt))
  if (nzchar(txt) && nchar(txt) < 500L) txt else NULL
}


#' Internal: Raise an Error for a Failed BrAPI Response
#'
#' `brapi_req()` disables httr2's own error handling so the server's
#' message can be read out of the body. This restores it, adding that
#' message where the server supplied one.
#'
#' @param resp An httr2 response.
#' @param con A `brapi_con` object.
#' @param endpoint Character. The endpoint requested.
#'
#' @return Invisibly `NULL`; called for its side effect.
#' @keywords internal
#' @noRd
brapi_stop_for_status <- function(resp, con = NULL, endpoint = NULL) {
  status <- tryCatch(resp_status(resp), error = function(e) NA_integer_)
  if (length(status) != 1L || is.na(status) || status < 400L) {
    return(invisible(NULL))
  }

  msgs <- brapi_server_message(resp)
  bullets <- c("BrAPI request failed (HTTP {status}).")
  if (length(msgs)) {
    bullets <- c(bullets, stats::setNames(msgs, rep("i", length(msgs))))
  }
  if (!is.null(endpoint)) {
    bullets <- c(bullets, "i" = "Endpoint: {.field {endpoint}}")
  }
  cli_abort(bullets)
}
