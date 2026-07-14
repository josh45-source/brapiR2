# ---- BrAPI Phenotyping Module ----
# Endpoints: /observationunits, /observations, /variables, /traits,
#            /scales, /methods, /images, /events


#' List Observation Units
#'
#' @inheritParams brapi_shared_params
#' @param studyDbId Character or NULL. Filter by study.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per observation unit (plot/plant/sample).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_observation_units(con, studyDbId = "study1")
#' }
#'
#' @export
brapi_observation_units <- function(con, studyDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(studyDbId)) query$studyDbId <- studyDbId
  brapi_get(con, "/observationunits", query = query)
}


#' List Observations
#'
#' @inheritParams brapi_shared_params
#' @param studyDbId Character or NULL. Filter by study.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per observation (trait measurement).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_observations(con, studyDbId = "study1")
#' }
#'
#' @export
brapi_observations <- function(con, studyDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(studyDbId)) query$studyDbId <- studyDbId
  brapi_get(con, "/observations", query = query)
}


#' List Observation Variables
#'
#' Returns the ontology of observation variables (trait + method + scale).
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per variable definition.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_observation_variables(con)
#' }
#'
#' @export
brapi_observation_variables <- function(con, ...) {
  brapi_get(con, "/variables", query = list(...))
}


#' List Traits
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per trait.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_traits(con)
#' }
#'
#' @export
brapi_traits <- function(con, ...) {
  brapi_get(con, "/traits", query = list(...))
}


#' List Scales
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per scale definition.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_scales(con)
#' }
#'
#' @export
brapi_scales <- function(con, ...) {
  brapi_get(con, "/scales", query = list(...))
}


#' List Methods
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per measurement method.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_methods(con)
#' }
#'
#' @export
brapi_methods <- function(con, ...) {
  brapi_get(con, "/methods", query = list(...))
}


#' List Images
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per image record.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_images(con)
#' }
#'
#' @export
brapi_images <- function(con, ...) {
  brapi_get(con, "/images", query = list(...))
}


#' List Events
#'
#' @inheritParams brapi_shared_params
#' @param studyDbId Character or NULL. Filter by study.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per event.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_events(con, studyDbId = "study1")
#' }
#'
#' @export
brapi_events <- function(con, studyDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(studyDbId)) query$studyDbId <- studyDbId
  brapi_get(con, "/events", query = query)
}


#' Search Observations
#'
#' @inheritParams brapi_shared_params
#' @param studyDbIds Character vector. Filter by study IDs.
#' @param observationVariableDbIds Character vector. Filter by variable IDs.
#' @param ... Additional search body parameters.
#'
#' @return A tibble of matching observations.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_search_observations(con, studyDbIds = "study1")
#' }
#'
#' @export
brapi_search_observations <- function(con,
                                      studyDbIds = NULL,
                                      observationVariableDbIds = NULL,
                                      ...) {
  body <- compact(list(
    studyDbIds                = studyDbIds,
    observationVariableDbIds  = observationVariableDbIds,
    ...
  ))
  brapi_post_search(con, "/search/observations", body = body)
}


#' Search Observation Variables
#'
#' @inheritParams brapi_shared_params
#' @param traitClasses Character vector. Filter by trait class.
#' @param ... Additional search body parameters.
#'
#' @return A tibble of matching observation variables.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_search_variables(con, traitClasses = "agronomic")
#' }
#'
#' @export
brapi_search_variables <- function(con, traitClasses = NULL, ...) {
  body <- compact(list(traitClasses = traitClasses, ...))
  brapi_post_search(con, "/search/variables", body = body)
}


#' Get Study Data in Wide Format
#'
#' A convenience function that fetches observation units and observations
#' for a given study and pivots them into a wide-format tibble with one
#' row per observation unit and one column per trait — ready for analysis.
#'
#' @inheritParams brapi_shared_params
#' @param studyDbId Character. The unique study identifier.
#'
#' @return A wide-format tibble with columns for plot metadata and
#'   one column per observed trait containing the measurement values.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' data <- brapi_study_data(con, "study1")
#' head(data)
#' }
#'
#' @importFrom tidyselect where
#' @export
brapi_study_data <- function(con, studyDbId) {
  obs <- brapi_observations(con, studyDbId = studyDbId)

  # Some servers do not implement the studyDbId GET filter on /observations.
  # Fall back to fetching all observations and filtering client-side.
  if (nrow(obs) == 0L) {
    all_obs <- brapi_observations(con)
    if ("studyDbId" %in% names(all_obs)) {
      obs <- dplyr::filter(all_obs, .data$studyDbId == studyDbId)
    }
  }

  if (nrow(obs) == 0L) {
    cli_alert_warning("No observations found for study {.val {studyDbId}}.")
    return(tibble())
  }

  # Select key columns and pivot to wide format
  id_cols <- intersect(
    c(
      "observationUnitDbId", "observationUnitName",
      "germplasmDbId", "germplasmName",
      "studyDbId", "studyName"
    ),
    names(obs)
  )
  value_col <- if ("value" %in% names(obs)) "value" else "observationValue"
  var_col <- if ("observationVariableName" %in% names(obs)) {
    "observationVariableName"
  } else {
    "observationVariableDbId"
  }

  obs_slim <- obs[, c(id_cols, var_col, value_col), drop = FALSE]

  wide <- pivot_wider(
    obs_slim,
    names_from  = !!rlang::sym(var_col),
    values_from = !!rlang::sym(value_col),
    values_fn   = list # keep as list-col when multiple obs per unit/variable
  )

  # Simplify list-columns that hold only one value per cell → plain vectors
  mutate(wide, dplyr::across(
    where(is.list),
    function(col) {
      if (all(lengths(col) <= 1L)) unlist(col, use.names = FALSE) else col
    }
  ))
}
