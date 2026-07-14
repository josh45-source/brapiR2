#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data %||% abort inform warn
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr bind_rows mutate select filter
#' @importFrom purrr map map_dfr map_chr map_lgl compact
#' @importFrom glue glue
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done
#'   cli_alert_success cli_alert_info cli_alert_warning cli_abort
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom httr2 request req_headers req_url_path_append req_url_query
#'   req_perform req_body_json resp_body_json resp_status req_retry
#'   req_auth_bearer_token req_method
#' @importFrom tidyr pivot_wider unnest
NULL


#' Internal: Shared Parameter Documentation
#'
#' Not a real function; exists only so other topics can
#' `@inheritParams brapi_shared_params` instead of repeating the
#' description of the `con` argument in every file.
#'
#' @param con A [brapi_connection()] object.
#'
#' @return `NULL`, invisibly.
#' @keywords internal
#' @rdname brapi_shared_params
brapi_shared_params <- function(con) NULL
