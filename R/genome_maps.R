# ---- BrAPI Genotyping Module: Genome Maps ----
# Endpoints: /maps, /maps/{mapDbId}, /maps/{mapDbId}/linkagegroups,
#            /markerpositions, /search/markerpositions
#
# Genome Maps is part of the Genotyping module in the BrAPI v2.1 spec, but
# gets its own file here since it is a distinct entity from Variants
# (R/genotyping.R): a MarkerPosition places a marker on a named
# `GenomeMap` (genetic, in cM, or physical, in bp - see the map's `type`
# and `unit`), which is a different coordinate system from a Variant's
# `start`/`referenceName` (a position on a reference assembly). A server
# can populate either, both, or neither; do not assume one implies the
# other.


#' List Genome Maps
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per genome map.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_maps(con)
#' }
#'
#' @export
brapi_maps <- function(con, ...) {
  brapi_get(con, "/maps", query = list(...))
}


#' Get a Single Genome Map by ID
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A single-row tibble with genome map details, including `type`
#'   (e.g. `"Genetic"` or `"Physical"`) and `unit` (e.g. `"cM"` or `"bp"`).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_map(con, "genome_map1")
#' }
#'
#' @export
brapi_map <- function(con, mapDbId) {
  brapi_get(con, glue("/maps/{mapDbId}"))
}


#' List the Linkage Groups of a Genome Map
#'
#' A linkage group is BrAPI's generic term for a named section of a map -
#' it may represent a chromosome, a scaffold, or a generic linkage group.
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_ids
#'
#' @return A tibble with one row per linkage group on the map.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_map_linkage_groups(con, "genome_map1")
#' }
#'
#' @export
brapi_map_linkage_groups <- function(con, mapDbId) {
  brapi_get(con, glue("/maps/{mapDbId}/linkagegroups"))
}


#' List Marker Positions
#'
#' Retrieves marker placements on genome maps from `/markerpositions`. A
#' position here is relative to a named [brapi_map()] (genetic, in cM, or
#' physical, in bp) - a different coordinate system from
#' [brapi_variants()]'s `start`/`referenceName`, which places a variant on
#' a reference assembly instead. A server may populate either, both, or
#' neither; one being empty does not imply the other is.
#'
#' @inheritParams brapi_shared_params
#' @param mapDbId Character or NULL. Filter by genome map.
#' @param variantDbId Character or NULL. Filter by a single marker/variant
#'   ID. For multiple IDs at once, use
#'   [brapi_search_marker_positions()] instead.
#' @param linkageGroupName Character or NULL. Filter by linkage group
#'   (e.g. chromosome) name.
#' @param minPosition Integer or NULL. Minimum position, inclusive.
#' @param maxPosition Integer or NULL. Maximum position, inclusive.
#'
#' @return A tibble with one row per marker placement.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_marker_positions(con, mapDbId = "genome_map1")
#' }
#'
#' @export
brapi_marker_positions <- function(con, mapDbId = NULL, variantDbId = NULL,
                                    linkageGroupName = NULL,
                                    minPosition = NULL, maxPosition = NULL,
                                    ...) {
  query <- list(...)
  if (!is.null(mapDbId)) query$mapDbId <- mapDbId
  if (!is.null(variantDbId)) query$variantDbId <- variantDbId
  if (!is.null(linkageGroupName)) query$linkageGroupName <- linkageGroupName
  if (!is.null(minPosition)) query$minPosition <- minPosition
  if (!is.null(maxPosition)) query$maxPosition <- maxPosition
  brapi_get(con, "/markerpositions", query = query)
}


#' Search Marker Positions
#'
#' The `/markerpositions` GET filter (see [brapi_marker_positions()])
#' takes a single `variantDbId`; this search endpoint accepts many IDs at
#' once, which is what [brapi_get_marker_map()] uses internally when
#' looking up positions for an entire variant set.
#'
#' @inheritParams brapi_shared_search
#' @param mapDbIds Character vector. Filter by genome map IDs.
#' @param variantDbIds Character vector. Filter by marker/variant IDs.
#' @param linkageGroupNames Character vector. Filter by linkage group
#'   names.
#' @param minPosition Integer. Minimum position, inclusive.
#' @param maxPosition Integer. Maximum position, inclusive.
#'
#' @return A tibble of matching marker positions.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' brapi_search_marker_positions(con, variantDbIds = c("variant01", "variant02"))
#' }
#'
#' @export
brapi_search_marker_positions <- function(con, mapDbIds = NULL,
                                           variantDbIds = NULL,
                                           linkageGroupNames = NULL,
                                           minPosition = NULL,
                                           maxPosition = NULL, ...) {
  body <- compact(list(
    mapDbIds          = mapDbIds,
    variantDbIds      = variantDbIds,
    linkageGroupNames = linkageGroupNames,
    minPosition       = minPosition,
    maxPosition       = maxPosition,
    ...
  ))
  brapi_post_search(con, "/search/markerpositions", body = body)
}
