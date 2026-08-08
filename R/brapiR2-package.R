#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data .env %||% abort inform warn
#' @importFrom tibble tibble as_tibble
#' @importFrom dplyr bind_rows mutate select filter
#' @importFrom purrr map map_dfr map_chr map_lgl compact
#' @importFrom glue glue
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning cli_abort
#' @importFrom cli cli_warn
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom httr2 request req_headers req_url_path_append req_url_query
#' @importFrom httr2 req_perform req_body_json resp_body_json resp_status
#' @importFrom httr2 req_retry req_auth_bearer_token req_method
#' @importFrom tidyr pivot_wider unnest
NULL


#' Internal: Shared Parameter Documentation
#'
#' Not a real function - no object is assigned here at all, only a
#' documentation topic. Other topics use `@inheritParams brapi_shared_params`
#' to pull in this description instead of repeating it in every file.
#' Deliberately limited to `con`: [brapi_shared_ids] and
#' [brapi_shared_filters] cover the (mutually exclusive, per parameter name)
#' ID and filter argument families, and are always inherited alongside this
#' one rather than merged into it, so that a function combining `con` with
#' either family never has two conflicting descriptions to choose between
#' for the same parameter name.
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @keywords internal
#' @name brapi_shared_params
NULL


#' Internal: Shared Identifier Parameter Documentation
#'
#' Not a real function - like [brapi_shared_params], this exists only as an
#' `@inheritParams brapi_shared_ids` target, for the *required* single-item
#' identifier arguments ("get this one thing by ID") that several endpoints
#' share. Compare [brapi_shared_filters], the equivalent for optional
#' (default `NULL`) filter arguments of the same names.
#'
#' @param studyDbId Character. The unique study identifier.
#' @param germplasmDbId Character. The unique germplasm identifier.
#' @param trialDbId Character. The unique trial identifier.
#' @param programDbId Character. The unique program identifier.
#'
#' @keywords internal
#' @name brapi_shared_ids
NULL


#' Internal: Shared Filter Parameter Documentation
#'
#' Not a real function - like [brapi_shared_params], this exists only as an
#' `@inheritParams brapi_shared_filters` target for the *optional* filter
#' arguments (default `NULL`) that several list-endpoints share, as opposed
#' to the required identifiers documented in [brapi_shared_ids].
#'
#' @param studyDbId Character or NULL. Filter by study.
#' @param variantSetDbId Character or NULL. Filter by variant set.
#' @param programDbId Character or NULL. Filter by program.
#' @param trialDbId Character or NULL. Filter by trial.
#'
#' @keywords internal
#' @name brapi_shared_filters
NULL


#' Internal: Shared Search-Body Parameter Documentation
#'
#' Not a real function - like [brapi_shared_params], this exists only as an
#' `@inheritParams brapi_shared_search` target for the `brapi_search_*()`
#' functions, which build a POST search body rather than a GET query
#' string. Bundles `con` together with that `...`, rather than requiring a
#' second `@inheritParams brapi_shared_params`, since the two topics define
#' `...` differently and inheriting both would leave it ambiguous which
#' description wins.
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional search body parameters.
#'
#' @keywords internal
#' @name brapi_shared_search
NULL
