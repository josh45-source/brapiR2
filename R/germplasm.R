# ---- BrAPI Germplasm Module ----
# Endpoints: /germplasm, /attributes, /crosses, /crossingprojects,
#            /seedlots, /pedigree, /search/pedigree


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
#' @inheritParams brapi_shared_ids
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
#' @inheritParams brapi_shared_ids
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
#' @inheritParams brapi_shared_ids
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


#' List Pedigree Nodes
#'
#' Retrieves a filtered subset of a pedigree tree via `/pedigree` - a batch
#' endpoint for pulling pedigree records across many germplasm in one call.
#' This is different from [brapi_germplasm_pedigree()], which retrieves one
#' germplasm's immediate pedigree via the germplasm sub-resource
#' (`/germplasm/{germplasmDbId}/pedigree`) and must be called once per
#' germplasm. Use `brapi_pedigree()` (or [brapi_search_pedigree()]) to pull
#' pedigree records for many germplasm at once - e.g. everything in a crop,
#' program, or family - in one or a few requests; use
#' [brapi_germplasm_pedigree()] when you already have a single germplasm ID
#' in hand.
#'
#' Each row is one pedigree node (one germplasm). The server only includes
#' a node's relatives if asked: set `includeParents`, `includeSiblings`,
#' and/or `includeProgeny` to `TRUE` to populate the `parents`, `siblings`,
#' and `progeny` list-columns, each holding a small tibble of related
#' germplasm (`germplasmDbId`, `germplasmName`, and `parentType` - `NA` for
#' siblings, which have none) that you can [tidyr::unnest()] when you need
#' one row per relationship rather than one row per node. Nodes are never
#' collapsed or flattened by default: a pedigree is graph-shaped (each node
#' has its own parents, siblings, and progeny edges), and the three
#' relation types don't share a common row shape, so there is no lossless
#' single flat table to fall back to.
#'
#' @inheritParams brapi_shared_params
#' @param germplasmDbId Character or NULL. Filter by germplasm.
#' @param includeParents Logical or NULL. Include each node's parents.
#' @param includeSiblings Logical or NULL. Include each node's siblings.
#' @param includeProgeny Logical or NULL. Include each node's progeny.
#' @param includeFullTree Logical or NULL. Recursively include every node
#'   reachable in the pedigree tree.
#' @param pedigreeDepth Integer or NULL. Number of levels to include up
#'   the tree (parents, grandparents, ...).
#' @param progenyDepth Integer or NULL. Number of levels to include down
#'   the tree (children, grandchildren, ...).
#'
#' @return A tibble with one row per pedigree node. `parents`, `siblings`,
#'   and `progeny`, when requested, are list-columns of small tibbles (one
#'   row per relative) rather than raw nested lists or a flattened table.
#'
#' @seealso [brapi_germplasm_pedigree()] for one germplasm's pedigree via
#'   the germplasm sub-resource; [brapi_search_pedigree()] for the same
#'   batch retrieval via `POST`, with a fuller set of filters.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_pedigree(con, includeParents = TRUE, includeProgeny = TRUE)
#' }
#'
#' @export
brapi_pedigree <- function(con, germplasmDbId = NULL, includeParents = NULL,
                            includeSiblings = NULL, includeProgeny = NULL,
                            includeFullTree = NULL, pedigreeDepth = NULL,
                            progenyDepth = NULL, ...) {
  query <- list(...)
  if (!is.null(germplasmDbId)) query$germplasmDbId <- germplasmDbId
  if (!is.null(includeParents)) query$includeParents <- includeParents
  if (!is.null(includeSiblings)) query$includeSiblings <- includeSiblings
  if (!is.null(includeProgeny)) query$includeProgeny <- includeProgeny
  if (!is.null(includeFullTree)) query$includeFullTree <- includeFullTree
  if (!is.null(pedigreeDepth)) query$pedigreeDepth <- pedigreeDepth
  if (!is.null(progenyDepth)) query$progenyDepth <- progenyDepth
  tidy_pedigree_nodes(brapi_get(con, "/pedigree", query = query))
}


#' Search Pedigree Nodes
#'
#' The `POST` equivalent of [brapi_pedigree()], taking the same
#' tree-shaping parameters plus the fuller set of filters
#' `/search/pedigree` accepts (crop, program, trial, study, accession
#' number, collection, family code, genus/species, and more - pass any of
#' these through `...`). See [brapi_pedigree()] for the shape of the
#' returned tibble and its relationship to [brapi_germplasm_pedigree()].
#'
#' @inheritParams brapi_shared_search
#' @param germplasmDbIds Character vector. Filter by germplasm IDs.
#' @param includeParents Logical. Include each node's parents.
#' @param includeSiblings Logical. Include each node's siblings.
#' @param includeProgeny Logical. Include each node's progeny.
#' @param includeFullTree Logical. Recursively include every node
#'   reachable in the pedigree tree.
#' @param pedigreeDepth Integer. Number of levels to include up the tree.
#' @param progenyDepth Integer. Number of levels to include down the tree.
#'
#' @return A tibble with one row per pedigree node; see [brapi_pedigree()]
#'   for column details.
#'
#' @seealso [brapi_pedigree()], [brapi_germplasm_pedigree()]
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_search_pedigree(con, includeParents = TRUE)
#' }
#'
#' @export
brapi_search_pedigree <- function(con, germplasmDbIds = NULL,
                                   includeParents = NULL,
                                   includeSiblings = NULL,
                                   includeProgeny = NULL,
                                   includeFullTree = NULL,
                                   pedigreeDepth = NULL,
                                   progenyDepth = NULL, ...) {
  body <- compact(list(
    germplasmDbIds  = germplasmDbIds,
    includeParents  = includeParents,
    includeSiblings = includeSiblings,
    includeProgeny  = includeProgeny,
    includeFullTree = includeFullTree,
    pedigreeDepth   = pedigreeDepth,
    progenyDepth    = progenyDepth,
    ...
  ))
  tidy_pedigree_nodes(brapi_post_search(con, "/search/pedigree", body = body))
}


#' Internal: Tidy Pedigree Node Relative List-Columns
#'
#' `/pedigree` and `/search/pedigree` return `PedigreeNode` records whose
#' `parents`, `siblings`, and `progeny` fields are each arrays of related
#' germplasm. `parse_brapi_result()` leaves these as raw nested lists;
#' this converts each element into a small tibble so callers can
#' `tidyr::unnest()` a relation column directly instead of hand-rolling
#' the conversion themselves.
#'
#' @param x A tibble as returned by `brapi_get()`/`brapi_post_search()`
#'   for a pedigree endpoint.
#'
#' @return `x`, with any of `parents`/`siblings`/`progeny` present
#'   converted from a list of raw nested lists to a list of tibbles.
#' @keywords internal
#' @noRd
tidy_pedigree_nodes <- function(x) {
  if (nrow(x) == 0L) {
    return(x)
  }
  relation_cols <- intersect(c("parents", "siblings", "progeny"), names(x))
  for (col in relation_cols) {
    x[[col]] <- lapply(x[[col]], relatives_to_tibble)
  }
  x
}


#' Internal: Convert One Node's Raw Relative List to a Tibble
#'
#' @param relatives A raw list of relative records (each a named list with
#'   `germplasmDbId`, `germplasmName`, and optionally `parentType`), or the
#'   scalar `NA` `parse_brapi_result()` substitutes when the field is
#'   absent (e.g. the corresponding `include*` flag was not set).
#'
#' @return A tibble with columns `germplasmDbId`, `germplasmName`,
#'   `parentType` (always `NA` for siblings, which have no parent type).
#' @keywords internal
#' @noRd
relatives_to_tibble <- function(relatives) {
  empty <- tibble(
    germplasmDbId = character(),
    germplasmName = character(),
    parentType    = character()
  )
  if (is.null(relatives) ||
        (length(relatives) == 1L && !is.list(relatives) && is.na(relatives))) {
    return(empty)
  }
  bind_rows(lapply(relatives, function(r) {
    tibble(
      germplasmDbId = r$germplasmDbId %||% NA_character_,
      germplasmName = r$germplasmName %||% NA_character_,
      parentType    = r$parentType %||% NA_character_
    )
  }))
}
