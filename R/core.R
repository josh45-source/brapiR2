# ---- BrAPI Core Module ----
# Endpoints: /programs, /trials, /studies, /locations, /seasons, /lists,
#            /people, /serverinfo


#' List Breeding Programs
#'
#' Retrieves a list of breeding programs from the BrAPI server.
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters passed to the API
#'   (e.g. `commonCropName = "rice"`, `programName = "IRRI"`).
#'
#' @return A tibble with one row per program.
#'
#' @section BrAPI endpoint:
#' `GET /programs` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Programs/Programs_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `abbreviation`, `programType`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_programs(con)
#'   brapi_programs(con, commonCropName = "rice")
#' }
#' }
#'
#' @export
brapi_programs <- function(con, ...) {
  brapi_get(con, "/programs", query = list(...))
}


#' Get a Single Program by ID
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble with program details.
#'
#' @section BrAPI endpoint:
#' `GET /programs/{programDbId}` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Programs/Programs_ProgramDbId_GET_PUT.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_program(con, "program1")
#' }
#' }
#'
#' @export
brapi_program <- function(con, programDbId) {
  brapi_get(con, glue("/programs/{programDbId}"))
}


#' List Trials
#'
#' Retrieves trials, optionally filtered by program.
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per trial.
#'
#' @section BrAPI endpoint:
#' `GET /trials` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Trials/Trials_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `active`, `contactDbId`, `locationDbId`, `searchDateRangeStart`,
#' `searchDateRangeEnd`, `trialPUI`, `sortBy`, `sortOrder`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_trials(con)
#' }
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
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble with trial details.
#'
#' @section BrAPI endpoint:
#' `GET /trials/{trialDbId}` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Trials/Trials_TrialDbId_GET_PUT.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_trial(con, "trial1")
#' }
#' }
#'
#' @export
brapi_trial <- function(con, trialDbId) {
  brapi_get(con, glue("/trials/{trialDbId}"))
}


#' List Studies
#'
#' Retrieves studies (occurrences/environments), optionally filtered by trial.
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per study.
#'
#' @section BrAPI endpoint:
#' `GET /studies` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Studies/Studies_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `studyType`, `locationDbId`, `seasonDbId`, `studyCode`, `studyPUI`,
#' `observationVariableDbId`, `active`, `sortBy`, `sortOrder`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_studies(con)
#'   brapi_studies(con, trialDbId = "trial1")
#' }
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
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble with study metadata.
#'
#' @section BrAPI endpoint:
#' `GET /studies/{studyDbId}` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Studies/Studies_StudyDbId_GET_PUT.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_study(con, "study1")
#' }
#' }
#'
#' @export
brapi_study <- function(con, studyDbId) {
  brapi_get(con, glue("/studies/{studyDbId}"))
}


#' List Locations
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters (e.g. `locationType`).
#'
#' @return A tibble with one row per location.
#'
#' @section BrAPI endpoint:
#' `GET /locations` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Locations/Locations_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `locationType`, `locationDbId`, `locationName`, `parentLocationDbId`,
#' `parentLocationName`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_locations(con)
#' }
#' }
#'
#' @export
brapi_locations <- function(con, ...) {
  brapi_get(con, "/locations", query = list(...))
}

#' Get a Single Location by ID
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble with location metadata, including
#'   coordinates where the server provides them.
#'
#' @section BrAPI endpoint:
#' `GET /locations/{locationDbId}` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Locations/Locations_LocationDbId_GET_PUT.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_location(con, "location_01")
#' }
#' }
#'
#' @export
brapi_location <- function(con, locationDbId) {
  brapi_get(con, glue("/locations/{locationDbId}"))
}



#' List Seasons
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters (e.g. `year`).
#'
#' @return A tibble with one row per season.
#'
#' @section BrAPI endpoint:
#' `GET /seasons` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Seasons/Seasons_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `seasonDbId`, `season`, `seasonName`, `year`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_seasons(con)
#' }
#' }
#'
#' @export
brapi_seasons <- function(con, ...) {
  brapi_get(con, "/seasons", query = list(...))
}


#' List Generic Lists
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters (e.g. `listType`).
#'
#' @return A tibble with one row per list.
#'
#' @section BrAPI endpoint:
#' `GET /lists` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Lists/Lists_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `listType`, `listName`, `listDbId`, `listSource`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_lists(con)
#' }
#' }
#'
#' @export
brapi_lists <- function(con, ...) {
  brapi_get(con, "/lists", query = list(...))
}

#' Get a Single List by ID, With Its Contents
#'
#' Unlike [brapi_lists()], which returns only list metadata, this returns
#' a single list together with its members in the `data` list-column.
#' `listType` says what the members are (for example `"germplasm"`).
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble of list metadata, with the list's members
#'   as a character vector in the `data` list-column.
#'
#' @section BrAPI endpoint:
#' `GET /lists/{listDbId}` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Lists/Lists_ListDbId_GET_PUT.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   lst <- brapi_list(con, "list1")
#'   lst$data[[1]]
#' }
#' }
#'
#' @export
brapi_list <- function(con, listDbId) {
  res <- brapi_get(con, glue("/lists/{listDbId}"))
  # The members arrive as a list of one-element lists; a character vector
  # is what a caller actually wants to pass to another function.
  if ("data" %in% names(res) && is.list(res$data)) {
    res$data <- lapply(res$data, function(x) {
      if (is.list(x) && all(lengths(x) == 1L)) {
        unlist(x, use.names = FALSE)
      } else {
        x
      }
    })
  }
  res
}



#' List People
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per person.
#'
#' @section BrAPI endpoint:
#' `GET /people` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/People/People_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `firstName`, `lastName`, `personDbId`, `userID`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_people(con)
#' }
#' }
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
#' @inheritParams brapi_shared_params
#'
#' @return A tibble of supported endpoints and their methods.
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
#'   brapi_server_info(con)
#' }
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
