# ---- BrAPI Germplasm Module ----
# Endpoints: /germplasm, /attributes, /crosses, /crossingprojects, /seedlots


#' List Germplasm
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters
#'   (e.g. `commonCropName`, `germplasmName`, `studyDbId`).
#'
#' @return A tibble with one row per germplasm accession.
#'
#' @export
brapi_germplasm <- function(con, ...) {
  brapi_get(con, "/germplasm", query = list(...))
}


#' Get a Single Germplasm by ID
#'
#' @param con A [brapi_connection()] object.
#' @param germplasmDbId Character. The unique germplasm identifier.
#'
#' @return A single-row tibble with germplasm details.
#'
#' @export
brapi_germplasm_detail <- function(con, germplasmDbId) {
  brapi_get(con, glue("/germplasm/{germplasmDbId}"))
}


#' Get Germplasm Pedigree
#'
#' @param con A [brapi_connection()] object.
#' @param germplasmDbId Character. The unique germplasm identifier.
#'
#' @return A tibble with pedigree information (parents, crosses).
#'
#' @export
brapi_germplasm_pedigree <- function(con, germplasmDbId) {
  brapi_get(con, glue("/germplasm/{germplasmDbId}/pedigree"))
}


#' Get Germplasm Progeny
#'
#' @param con A [brapi_connection()] object.
#' @param germplasmDbId Character. The unique germplasm identifier.
#'
#' @return A tibble with progeny information.
#'
#' @export
brapi_germplasm_progeny <- function(con, germplasmDbId) {
  brapi_get(con, glue("/germplasm/{germplasmDbId}/progeny"))
}


#' List Germplasm Attributes
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per attribute definition.
#'
#' @export
brapi_germplasm_attributes <- function(con, ...) {
  brapi_get(con, "/attributes", query = list(...))
}


#' List Crosses
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per cross.
#'
#' @export
brapi_crosses <- function(con, ...) {
  brapi_get(con, "/crosses", query = list(...))
}


#' List Crossing Projects
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per crossing project.
#'
#' @export
brapi_crossing_projects <- function(con, ...) {
  brapi_get(con, "/crossingprojects", query = list(...))
}


#' List Seed Lots
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per seed lot.
#'
#' @export
brapi_seed_lots <- function(con, ...) {
  brapi_get(con, "/seedlots", query = list(...))
}


#' Search Germplasm
#'
#' Performs a BrAPI search for germplasm records matching the given criteria.
#'
#' @param con A [brapi_connection()] object.
#' @param germplasmNames Character vector. Filter by germplasm names.
#' @param germplasmDbIds Character vector. Filter by database IDs.
#' @param commonCropNames Character vector. Filter by crop name.
#' @param ... Additional body parameters for the search request.
#'
#' @return A tibble of matching germplasm records.
#'
#' @export
brapi_search_germplasm <- function(con,
                                   germplasmNames = NULL,
                                   germplasmDbIds = NULL,
                                   commonCropNames = NULL,
                                   ...) {
  body <- compact(list(
    germplasmNames  = germplasmNames,
    germplasmDbIds  = germplasmDbIds,
    commonCropNames = commonCropNames,
    ...
  ))
  brapi_post_search(con, "/search/germplasm", body = body)
}
