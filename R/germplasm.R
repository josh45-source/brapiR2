# ---- BrAPI Germplasm Module ----
# Endpoints: /germplasm, /attributes, /crosses, /crossingprojects, /seedlots


#' List Germplasm
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters
#'   (e.g. `commonCropName`, `germplasmName`, `studyDbId`).
#'
#' @return A tibble with one row per germplasm accession.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_germplasm(con)
#' }
#'
#' @export
brapi_germplasm <- function(con, ...) {
  brapi_get(con, "/germplasm", query = list(...))
}


#' Get a Single Germplasm by ID
#'
#' @inheritParams brapi_shared_params
#' @param germplasmDbId Character. The unique germplasm identifier.
#'
#' @return A single-row tibble with germplasm details.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_germplasm_detail(con, "germplasm1")
#' }
#'
#' @export
brapi_germplasm_detail <- function(con, germplasmDbId) {
  brapi_get(con, glue("/germplasm/{germplasmDbId}"))
}


#' Get Germplasm Pedigree
#'
#' @inheritParams brapi_shared_params
#' @param germplasmDbId Character. The unique germplasm identifier.
#'
#' @return A tibble with pedigree information (parents, crosses).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_germplasm_pedigree(con, "germplasm1")
#' }
#'
#' @export
brapi_germplasm_pedigree <- function(con, germplasmDbId) {
  brapi_get(con, glue("/germplasm/{germplasmDbId}/pedigree"))
}


#' Get Germplasm Progeny
#'
#' @inheritParams brapi_shared_params
#' @param germplasmDbId Character. The unique germplasm identifier.
#'
#' @return A tibble with progeny information.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_germplasm_progeny(con, "germplasm1")
#' }
#'
#' @export
brapi_germplasm_progeny <- function(con, germplasmDbId) {
  brapi_get(con, glue("/germplasm/{germplasmDbId}/progeny"))
}


#' List Germplasm Attributes
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per attribute definition.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_germplasm_attributes(con)
#' }
#'
#' @export
brapi_germplasm_attributes <- function(con, ...) {
  brapi_get(con, "/attributes", query = list(...))
}


#' List Crosses
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per cross.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_crosses(con)
#' }
#'
#' @export
brapi_crosses <- function(con, ...) {
  brapi_get(con, "/crosses", query = list(...))
}


#' List Crossing Projects
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per crossing project.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_crossing_projects(con)
#' }
#'
#' @export
brapi_crossing_projects <- function(con, ...) {
  brapi_get(con, "/crossingprojects", query = list(...))
}


#' List Seed Lots
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per seed lot.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_seed_lots(con)
#' }
#'
#' @export
brapi_seed_lots <- function(con, ...) {
  brapi_get(con, "/seedlots", query = list(...))
}


#' Search Germplasm
#'
#' Performs a BrAPI search for germplasm records matching the given criteria.
#'
#' @inheritParams brapi_shared_params
#' @param germplasmNames Character vector. Filter by germplasm names.
#' @param germplasmDbIds Character vector. Filter by database IDs.
#' @param commonCropNames Character vector. Filter by crop name.
#' @param ... Additional body parameters for the search request.
#'
#' @return A tibble of matching germplasm records.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_search_germplasm(con, commonCropNames = "Tomatillo")
#' }
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
