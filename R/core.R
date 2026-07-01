# ---- BrAPI Core Module ----
# Endpoints: /programs, /trials, /studies, /locations, /seasons, /lists, /people, /serverinfo


#' List Breeding Programs
#'
#' Retrieves a list of breeding programs from the BrAPI server.
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters passed to the API
#'   (e.g. `commonCropName = "rice"`, `programName = "IRRI"`).
#'
#' @return A tibble with one row per program.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_programs(con)
#' brapi_programs(con, commonCropName = "rice")
#' }
#'
#' @export
brapi_programs <- function(con, ...) {
  brapi_get(con, "/programs", query = list(...))
}


#' Get a Single Program by ID
#'
#' @param con A [brapi_connection()] object.
#' @param programDbId Character. The unique program identifier.
#'
#' @return A single-row tibble with program details.
#'
#' @export
brapi_program <- function(con, programDbId) {
  brapi_get(con, glue("/programs/{programDbId}"))
}


#' List Trials
#'
#' Retrieves trials, optionally filtered by program.
#'
#' @param con A [brapi_connection()] object.
#' @param programDbId Character or NULL. Filter by program.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per trial.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_trials(con)
#' }
#'
#' @export
brapi_trials <- function(con, programDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(programDbId)) query$programDbId <- programDbId
  brapi_get(con, "/trials", query = query)
}


#' Get a Single Trial by ID
#'
#' @param con A [brapi_connection()] object.
#' @param trialDbId Character. The unique trial identifier.
#'
#' @return A single-row tibble with trial details.
#'
#' @export
brapi_trial <- function(con, trialDbId) {
  brapi_get(con, glue("/trials/{trialDbId}"))
}


#' List Studies
#'
#' Retrieves studies (occurrences/environments), optionally filtered by trial.
#'
#' @param con A [brapi_connection()] object.
#' @param trialDbId Character or NULL. Filter by trial.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per study.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_studies(con)
#' brapi_studies(con, trialDbId = "trial_01")
#' }
#'
#' @export
brapi_studies <- function(con, trialDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(trialDbId)) query$trialDbId <- trialDbId
  brapi_get(con, "/studies", query = query)
}


#' Get a Single Study by ID
#'
#' @param con A [brapi_connection()] object.
#' @param studyDbId Character. The unique study identifier.
#'
#' @return A single-row tibble with study metadata.
#'
#' @export
brapi_study <- function(con, studyDbId) {
  brapi_get(con, glue("/studies/{studyDbId}"))
}


#' List Locations
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters (e.g. `locationType`).
#'
#' @return A tibble with one row per location.
#'
#' @export
brapi_locations <- function(con, ...) {
  brapi_get(con, "/locations", query = list(...))
}


#' List Seasons
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters (e.g. `year`).
#'
#' @return A tibble with one row per season.
#'
#' @export
brapi_seasons <- function(con, ...) {
  brapi_get(con, "/seasons", query = list(...))
}


#' List Generic Lists
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters (e.g. `listType`).
#'
#' @return A tibble with one row per list.
#'
#' @export
brapi_lists <- function(con, ...) {
  brapi_get(con, "/lists", query = list(...))
}


#' List People
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per person.
#'
#' @export
brapi_people <- function(con, ...) {
  brapi_get(con, "/people", query = list(...))
}


#' Get Server Info
#'
#' Returns a tibble of BrAPI calls supported by the server. Each row is one
#' supported endpoint with columns for service name, HTTP methods, BrAPI
#' versions, and content/data types.
#'
#' @param con A [brapi_connection()] object.
#'
#' @return A tibble of supported endpoints and their methods.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_server_info(con)
#' }
#'
#' @export
brapi_server_info <- function(con) {
  validate_con(con)
  # /serverinfo is a single metadata object, not a paginated list.
  # Extract the `calls` array which describes supported endpoints.
  # Use simplifyVector = TRUE so jsonlite flattens single-element arrays
  # into scalars and multi-element arrays into list-columns automatically.
  resp <- brapi_req(con, "/serverinfo") |> req_perform()
  body <- resp_body_json(resp, simplifyVector = TRUE)
  calls <- body$result$calls
  if (is.null(calls) || length(calls) == 0L) {
    return(tibble())
  }
  as_tibble(calls)
}
