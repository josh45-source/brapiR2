# ---- BrAPI Phenotyping Module ----
# Endpoints: /observationunits, /observations, /variables, /traits,
#            /scales, /methods, /images, /events, /ontologies


#' List Observation Units
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per observation unit (plot/plant/sample).
#'
#' @section BrAPI endpoint:
#' `GET /observationunits` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/ObservationUnits/ObservationUnits_GET_POST_PUT.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `observationUnitDbId`, `observationUnitName`, `locationDbId`,
#' `seasonDbId`, `includeObservations`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_observation_units(con, studyDbId = "study1")
#' }
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
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per observation (trait measurement).
#'
#' @section BrAPI endpoint:
#' `GET /observations` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Observations/Observations_GET_POST_PUT.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `observationDbId`, `observationUnitDbId`, `observationVariableDbId`,
#' `locationDbId`, `seasonDbId`, `observationTimeStampRangeStart`,
#' `observationTimeStampRangeEnd`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_observations(con, studyDbId = "study1")
#' }
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
#'
#' @return A tibble with one row per variable definition.
#'
#' @seealso [brapi_ontologies()] and [brapi_ontology()] to resolve the
#'   ontology a variable's `ontologyDbId`/`ontologyReference` points to.
#'
#' @section BrAPI endpoint:
#' `GET /variables` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/ObservationVariables/Variables_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `observationVariableDbId`, `observationVariableName`,
#' `observationVariablePUI`, `traitClass`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_observation_variables(con)
#' }
#' }
#'
#' @export
brapi_observation_variables <- function(con, ...) {
  brapi_get(con, "/variables", query = list(...))
}


#' List Traits
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per trait.
#'
#' @seealso [brapi_ontologies()] and [brapi_ontology()] to resolve the
#'   ontology a trait's `ontologyDbId`/`ontologyReference` points to.
#'
#' @section BrAPI endpoint:
#' `GET /traits` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Traits/Traits_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `traitDbId`, `observationVariableDbId`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_traits(con)
#' }
#' }
#'
#' @export
brapi_traits <- function(con, ...) {
  brapi_get(con, "/traits", query = list(...))
}


#' List Scales
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per scale definition.
#'
#' @seealso [brapi_ontologies()] and [brapi_ontology()] to resolve the
#'   ontology a scale's `ontologyDbId`/`ontologyReference` points to.
#'
#' @section BrAPI endpoint:
#' `GET /scales` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Scales/Scales_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `scaleDbId`, `observationVariableDbId`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_scales(con)
#' }
#' }
#'
#' @export
brapi_scales <- function(con, ...) {
  brapi_get(con, "/scales", query = list(...))
}


#' List Methods
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per measurement method.
#'
#' @seealso [brapi_ontologies()] and [brapi_ontology()] to resolve the
#'   ontology a method's `ontologyDbId`/`ontologyReference` points to.
#'
#' @section BrAPI endpoint:
#' `GET /methods` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Methods/Methods_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `methodDbId`, `observationVariableDbId`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_methods(con)
#' }
#' }
#'
#' @export
brapi_methods <- function(con, ...) {
  brapi_get(con, "/methods", query = list(...))
}


#' List Ontologies
#'
#' Retrieves the ontologies registered on the server: metadata about each
#' ontology (name, version, authors, description, ...), not the trait
#' terms that belong to it. [brapi_traits()], [brapi_scales()],
#' [brapi_methods()], and [brapi_observation_variables()] each carry an
#' ontology reference back to one of these records.
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per ontology.
#'
#' @seealso [brapi_ontology()] for a single ontology by ID;
#'   [brapi_traits()], [brapi_scales()], [brapi_methods()], and
#'   [brapi_observation_variables()] for the records that reference these
#'   ontologies.
#'
#' @section BrAPI endpoint:
#' `GET /ontologies` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Ontologies/Ontologies_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `ontologyName`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_ontologies(con)
#' }
#' }
#'
#' @export
brapi_ontologies <- function(con, ...) {
  brapi_get(con, "/ontologies", query = list(...))
}


#' Get a Single Ontology by ID
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble with ontology details.
#'
#' @seealso [brapi_ontologies()]; [brapi_traits()], [brapi_scales()],
#'   [brapi_methods()], and [brapi_observation_variables()] for the
#'   records that reference ontologies.
#'
#' @section BrAPI endpoint:
#' `GET /ontologies/{ontologyDbId}` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Ontologies/Ontologies_OntologyDbId_GET_PUT.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_ontology(con, "O_001")
#' }
#' }
#'
#' @export
brapi_ontology <- function(con, ontologyDbId) {
  brapi_get(con, paste0(
    "/ontologies/", brapi_id_segment(ontologyDbId, "ontologyDbId")
  ))
}


#' List Images
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per image record.
#'
#' @section BrAPI endpoint:
#' `GET /images` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Images/Images_GET_POST.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `imageDbId`, `imageName`, `observationUnitDbId`, `observationDbId`,
#' `descriptiveOntologyTerm`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_images(con)
#' }
#' }
#'
#' @export
brapi_images <- function(con, ...) {
  brapi_get(con, "/images", query = list(...))
}


#' List Events
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per event.
#'
#' @section BrAPI endpoint:
#' `GET /events` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Events/Events_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `observationUnitDbId`, `eventDbId`, `eventType`, `dateRangeStart`,
#' `dateRangeEnd`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_events(con, studyDbId = "study1")
#' }
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
#' @inheritParams brapi_shared_search
#' @param studyDbIds Character vector. Filter by study IDs.
#' @param observationVariableDbIds Character vector. Filter by variable IDs.
#'
#' @return A tibble of matching observations.
#'
#' @section BrAPI endpoint:
#' `POST /search/observations` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/Observations/Search_Observations_POST.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_search_observations(con, studyDbIds = "study1")
#' }
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
#' @inheritParams brapi_shared_search
#' @param traitClasses Character vector. Filter by trait class.
#'
#' @return A tibble of matching observation variables.
#'
#' @section BrAPI endpoint:
#' `POST /search/variables` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/ObservationVariables/Search_Variables_POST.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_search_variables(con, traitClasses = "agronomic")
#' }
#' }
#'
#' @export
brapi_search_variables <- function(con, traitClasses = NULL, ...) {
  body <- compact(list(traitClasses = traitClasses, ...))
  brapi_post_search(con, "/search/variables", body = body)
}


#' Get Study Data in Wide Format
#'
#' A convenience function that fetches a study's observations and pivots
#' them into a wide-format tibble with one row per observation unit and one
#' column per trait — ready for analysis.
#'
#' Some servers ignore the `studyDbId` filter on `/observations` and return
#' nothing for it; the public BrAPI test server (test-server.brapi.org) is
#' one. Set `fallback = TRUE` to fetch every observation on such a server
#' and filter them locally. That can mean a very large download on a
#' production server, so it is off by default.
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#' @param fallback Logical. If the filtered request returns no
#'   observations, fetch all observations on the server and filter them to
#'   `studyDbId` locally. Default `FALSE`.
#'
#' @return A wide-format tibble with the observation unit, germplasm and
#'   study identifier columns the server provides, and one character column
#'   per observed trait holding its values. A cell with repeated
#'   measurements is a list of them.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   # The test server ignores the studyDbId filter, so opt in to the fallback
#'   data <- brapi_study_data(con, "study1", fallback = TRUE)
#'   head(data)
#' }
#' }
#'
#' @importFrom tidyselect where
#' @export
brapi_study_data <- function(con, studyDbId, fallback = FALSE) {
  if (!rlang::is_bool(fallback)) {
    cli_abort("{.arg fallback} must be {.code TRUE} or {.code FALSE}.")
  }

  obs <- brapi_observations(con, studyDbId = studyDbId)

  # Some servers do not implement the studyDbId GET filter on /observations.
  # On request, fall back to fetching all observations and filtering
  # client-side.
  if (nrow(obs) == 0L && fallback) {
    all_obs <- brapi_observations(con)
    if ("studyDbId" %in% names(all_obs)) {
      # .env$studyDbId (not bare studyDbId) is required here: dplyr's data
      # mask resolves an unqualified name to the data column first, so
      # `.data$studyDbId == studyDbId` would silently compare the column to
      # itself (always TRUE) since the argument is also named studyDbId.
      obs <- dplyr::filter(
        all_obs, .data$studyDbId == .env$studyDbId # nolint
      )
    }
  }

  # A server may accept the studyDbId filter and ignore it, returning every
  # study's observations. The function promises one study, so filter here
  # too rather than trusting the parameter was applied.
  if (nrow(obs) > 0L && "studyDbId" %in% names(obs)) {
    others <- setdiff(unique(obs$studyDbId), studyDbId)
    if (length(others)) {
      obs <- dplyr::filter(obs, .data$studyDbId == .env$studyDbId) # nolint
      cli_alert_info(
        "Server returned observations for {length(others) + 1} studies; filtered to {.val {studyDbId}}."
      )
    }
  }

  if (nrow(obs) == 0L) {
    msg <- c("!" = "No observations found for study {.val {studyDbId}}.")
    if (!fallback) {
      msg <- c(msg, "i" = paste(
        "Some servers, including the public BrAPI test server",
        "(test-server.brapi.org), ignore the {.field studyDbId} filter on",
        "{.field /observations}. Try {.code fallback = TRUE} to fetch all",
        "observations and filter them locally."
      ))
    }
    cli::cli_inform(msg)
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
  value_col <- intersect(c("value", "observationValue"), names(obs))[1]
  if (is.na(value_col)) {
    cli_abort(c(
      "Observations for study {.val {studyDbId}} have no values.",
      "x" = paste(
        "The server's records have neither a {.field value} nor an",
        "{.field observationValue} field."
      )
    ))
  }
  var_col <- if ("observationVariableName" %in% names(obs)) {
    "observationVariableName"
  } else {
    "observationVariableDbId"
  }

  # Some servers return the same observation more than once, which would
  # otherwise pivot into cells holding several copies of one value. A
  # duplicate is the same observationDbId (or, without one, the same whole
  # record): two measurements that merely share a value are both kept.
  n_before <- nrow(obs)
  dup <- if ("observationDbId" %in% names(obs)) {
    duplicated(obs$observationDbId)
  } else {
    duplicated(obs)
  }
  obs <- obs[!dup, , drop = FALSE]
  if (nrow(obs) < n_before) {
    cli_alert_info(
      "Dropped {n_before - nrow(obs)} duplicate observation record{?s}."
    )
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
      if (!all(lengths(col) <= 1L)) return(col)
      vapply(col, function(x) {
        if (length(x) == 0L) NA_character_ else trimws(as.character(x[[1]]))
      }, character(1))
    }
  ))
}
