# ---- Utility Functions ----


#' Ping a BrAPI Server
#'
#' Tests whether the BrAPI server is reachable and responding.
#'
#' A ping uses a timeout of at most 10 seconds and doesn't retry, so an
#' unreachable server is reported quickly.
#'
#' @inheritParams brapi_shared_params
#'
#' @return Logical, invisibly. `TRUE` if `/serverinfo` answers with HTTP 200
#'   and a JSON body, or with 401/403 (the server is up but needs
#'   authentication); `FALSE` otherwise. The HTTP status is attached as the
#'   `"status"` attribute (`NA` if the server could not be reached).
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
brapi_ping <- function(con, ...) {
  validate_con(con)
  tryCatch(
    {
      resp <- brapi_req(con, "/serverinfo") |>
        req_url_query(!!!brapi_query_values(compact(list(...)))) |>
        req_retry(max_tries = 1) |>
        req_timeout(min(con$timeout %||% 10, 10)) |>
        req_perform()
      status <- resp_status(resp)
      if (status %in% c(401L, 403L)) {
        cli_alert_success(paste(
          "Server {.url {con$base_url}} is reachable but requires",
          "authentication (HTTP {status})."
        ))
        return(invisible(structure(TRUE, status = status)))
      }
      if (status != 200L) {
        cli_alert_warning("Server returned status {status}.")
        return(invisible(structure(FALSE, status = status)))
      }
      is_json <- tryCatch(
        {
          resp_body_json(resp)
          TRUE
        },
        error = function(e) FALSE
      )
      if (!is_json) {
        cli_alert_warning("Server returned status {status} but not JSON.")
        return(invisible(structure(FALSE, status = status)))
      }
      cli_alert_success("Server {.url {con$base_url}} is reachable.")
      invisible(structure(TRUE, status = status))
    },
    error = function(e) {
      cli_alert_warning("Cannot reach {.url {con$base_url}}: {e$message}")
      invisible(structure(FALSE, status = NA_integer_))
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
#' if (brapi_ping(con)) {
#'   brapi_endpoints(con)
#' }
#' }
#'
#' @export
brapi_endpoints <- function(con, ...) {
  brapi_server_info(con, ...)
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


#' Internal: Check and Encode an Identifier for a URL Path
#'
#' By-ID functions put the identifier into the request path, so it must be
#' one value, and characters such as `?` and spaces must be percent-encoded
#' or they change the URL. A `/` cannot be sent at all: httr2 (>= 1.1)
#' decodes `%2F` back to a path separator when it adds the query string, so
#' such an ID is refused rather than sent to the wrong endpoint. A whole
#' number (Breedbase IDs often are) is accepted and written without
#' scientific notation.
#'
#' @param id The identifier the caller passed.
#' @param arg Character. The argument's name, for the error message.
#' @param call The caller's environment, for the error message.
#'
#' @return `id` as a percent-encoded string.
#' @keywords internal
#' @noRd
brapi_id_segment <- function(id, arg, call = rlang::caller_env()) {
  if (is.numeric(id) && length(id) == 1L && !is.na(id) && id == round(id)) {
    id <- format(id, scientific = FALSE, trim = TRUE)
  }
  if (!is.character(id) || length(id) != 1L || is.na(id) || !nzchar(id)) {
    cli_abort(
      "{.arg {arg}} must be a single non-empty string.",
      call = call
    )
  }
  if (grepl("/", id, fixed = TRUE)) {
    cli_abort(
      c(
        "{.arg {arg}} {.val {id}} contains {.val /}, which can't be sent in
          a URL path.",
        "i" = "Filter the list endpoint by {.arg {arg}} instead."
      ),
      call = call
    )
  }
  utils::URLencode(id, reserved = TRUE)
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
  if (!is.null(con)) {
    bullets <- c(bullets, "i" = "Server: {.url {con$base_url}}")
  }
  if (!is.null(endpoint)) {
    bullets <- c(bullets, "i" = "Endpoint: {.field {endpoint}}")
  }
  cli_abort(bullets)
}
