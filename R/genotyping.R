# ---- BrAPI Genotyping Module ----
# Endpoints: /samples, /variants, /variantsets, /calls, /callsets,
#            /references, /referencesets, /allelematrix
# Genome Maps (/maps, /markerpositions) lives in R/genome_maps.R instead;
# brapi_get_marker_map() below builds on top of it.


#' List Samples
#'
#' @inheritParams brapi_shared_params
#' @param ... Additional query parameters
#'   (e.g. `studyDbId`, `germplasmDbId`, `observationUnitDbId`).
#'
#' @return A tibble with one row per sample.
#'
#' @section BrAPI endpoint:
#' `GET /samples` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/Samples/Samples_GET_POST_PUT.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `sampleDbId`, `sampleName`, `sampleGroupDbId`, `observationUnitDbId`,
#' `plateDbId`, `plateName`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_samples(con)
#' }
#' }
#'
#' @export
brapi_samples <- function(con, ...) {
  brapi_get(con, "/samples", query = list(...))
}


#' List Variants (Markers/SNPs)
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per variant.
#'
#' @section BrAPI endpoint:
#' `GET /variants` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/Variants/Variants_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `variantDbId`, `variantSetDbId`, `referenceDbId`, `referenceSetDbId`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_variants(con, variantSetDbId = "variantset1")
#' }
#' }
#'
#' @export
brapi_variants <- function(con, variantSetDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(variantSetDbId)) query$variantSetDbId <- variantSetDbId
  brapi_get(con, "/variants", query = query)
}


#' List Variant Sets (Datasets)
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per variant set.
#'
#' @section BrAPI endpoint:
#' `GET /variantsets` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/VariantSets/VariantSets_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `variantSetDbId`, `variantDbId`, `callSetDbId`, `referenceSetDbId`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_variant_sets(con)
#' }
#' }
#'
#' @export
brapi_variant_sets <- function(con, studyDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(studyDbId)) query$studyDbId <- studyDbId
  brapi_get(con, "/variantsets", query = query)
}


#' List Genotype Calls
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#'
#' @return A tibble with one row per genotype call.
#'
#' @section BrAPI endpoint:
#' `GET /calls` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/Calls/Calls_GET_PUT.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `callSetDbId`, `variantDbId`, `variantSetDbId`, `expandHomozygotes`,
#' `unknownString`, `sepPhased`, `sepUnphased`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_calls(con, variantSetDbId = "variantset1")
#' }
#' }
#'
#' @export
brapi_calls <- function(con, variantSetDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(variantSetDbId)) query$variantSetDbId <- variantSetDbId
  brapi_get(con, "/calls", query = query)
}


#' List Call Sets (Samples with Genotype Data)
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per call set.
#'
#' @section BrAPI endpoint:
#' `GET /callsets` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/CallSets/CallSets_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `callSetDbId`, `callSetName`, `variantSetDbId`, `sampleDbId`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_call_sets(con)
#' }
#' }
#'
#' @export
brapi_call_sets <- function(con, ...) {
  brapi_get(con, "/callsets", query = list(...))
}


#' List References (Chromosomes/Contigs)
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per reference sequence.
#'
#' @section BrAPI endpoint:
#' `GET /references` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/References/References_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `referenceDbId`, `referenceSetDbId`, `accession`, `md5checksum`,
#' `isDerived`, `minLength`, `maxLength`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_references(con)
#' }
#' }
#'
#' @export
brapi_references <- function(con, ...) {
  brapi_get(con, "/references", query = list(...))
}


#' List Reference Sets (Genome Assemblies)
#'
#' @inheritParams brapi_shared_params
#'
#' @return A tibble with one row per reference set.
#'
#' @section BrAPI endpoint:
#' `GET /referencesets` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/ReferenceSets/ReferenceSets_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `referenceSetDbId`, `accession`, `assemblyPUI`, `md5checksum`.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_reference_sets(con)
#' }
#' }
#'
#' @export
brapi_reference_sets <- function(con, ...) {
  brapi_get(con, "/referencesets", query = list(...))
}


#' Get Allele Matrix
#'
#' Retrieves genotype calls from the `/allelematrix` endpoint and returns a
#' tidy tibble with one row per (variant, callSet) combination. The
#' `/allelematrix` response has a unique structure (2-D pagination, no
#' `result$data` envelope) so it cannot use the generic `brapi_get()`.
#'
#' @inheritParams brapi_shared_params
#' @inheritParams brapi_shared_filters
#' @param ... Additional query parameters
#'   (e.g. `expandHomozygotes`, `unknownString`, `sepPhased`, `sepUnphased`).
#'
#' @return A tibble with columns `variantDbId`, `callSetDbId`, `genotype`.
#'
#' @section BrAPI endpoint:
#' `GET /allelematrix` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/AlleleMatrix/AlleleMatrix_GET.yaml).
#'
#' Query parameters the specification defines, which may be passed
#' through `...`:
#'
#' `dimensionVariantPage`, `dimensionVariantPageSize`,
#' `dimensionCallSetPage`, `dimensionCallSetPageSize`.
#'
#' Both dimensions are paged automatically, `con$page_size` variants by
#' `con$page_size` call sets at a time, unless a `dimension*PageSize` is
#' given. Supplying `dimensionVariantPage` or `dimensionCallSetPage`
#' fetches only that page of that dimension.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_allele_matrix(con, variantSetDbId = "variantset1")
#' }
#' }
#'
#' @export
brapi_allele_matrix <- function(con, variantSetDbId = NULL, ...) {
  validate_con(con)

  query <- list(...)
  if (!is.null(variantSetDbId)) query$variantSetDbId <- variantSetDbId

  gt <- fetch_allele_matrix_pages(con, query)

  if (nrow(gt) == 0L || ncol(gt) == 0L) {
    return(tibble())
  }

  # One row per (variant, call set), all of a variant's call sets together.
  tibble(
    variantDbId = rep(rownames(gt), each = ncol(gt)),
    callSetDbId = rep(colnames(gt), times = nrow(gt)),
    genotype    = as.vector(t(gt))
  )
}


#' Internal: Page Through the Allele Matrix Endpoint
#'
#' `/allelematrix` is paged in two dimensions, variants and call sets,
#' each with its own `dimension*Page`/`dimension*PageSize` parameters and
#' its own entry in `result$pagination`. This walks every page of both and
#' assembles the blocks into one genotype matrix.
#'
#' @inheritParams brapi_shared_params
#' @param query Named list. Query parameters, including any user-supplied
#'   filters. A `dimensionVariantPage` or `dimensionCallSetPage` already in
#'   `query` pins that dimension to the one page.
#'
#' @return A character matrix of genotype calls, variants in rows and call
#'   sets in columns, with the IDs as dimnames.
#' @keywords internal
#' @noRd
fetch_allele_matrix_pages <- function(con, query) {
  # `[[` rather than `$`: `$` would partially match dimensionVariantPage
  # to dimensionVariantPageSize.
  query[["dimensionVariantPageSize"]] <-
    query[["dimensionVariantPageSize"]] %||% con$page_size
  query[["dimensionCallSetPageSize"]] <-
    query[["dimensionCallSetPageSize"]] %||% con$page_size
  pinned_v <- query[["dimensionVariantPage"]]
  pinned_cs <- query[["dimensionCallSetPage"]]
  query <- brapi_query_values(query)

  blocks <- list()
  totals <- c(VARIANTS = 1L, CALLSETS = 1L)
  v_page <- 0L
  repeat {
    cs_page <- 0L
    repeat {
      query[["dimensionVariantPage"]] <- pinned_v %||% v_page
      query[["dimensionCallSetPage"]] <- pinned_cs %||% cs_page

      resp <- brapi_req(con, "/allelematrix") |>
        req_url_query(!!!query) |>
        req_perform()
      brapi_stop_for_status(resp, con, "/allelematrix")
      body <- resp_body_json(resp, simplifyVector = FALSE)

      for (p in body$result$pagination) {
        if (isTRUE(p$dimension %in% names(totals))) {
          totals[[p$dimension]] <- p$totalPages %||% 1L
        }
      }
      blocks[[length(blocks) + 1L]] <- allele_matrix_block(body$result)

      cs_page <- cs_page + 1L
      if (!is.null(pinned_cs) || cs_page >= totals[["CALLSETS"]]) break
    }
    v_page <- v_page + 1L
    if (!is.null(pinned_v) || v_page >= totals[["VARIANTS"]]) break
  }

  variant_ids <- unique(unlist(lapply(blocks, rownames)))
  callset_ids <- unique(unlist(lapply(blocks, colnames)))
  gt <- matrix(
    NA_character_,
    nrow = length(variant_ids), ncol = length(callset_ids),
    dimnames = list(variant_ids, callset_ids)
  )
  for (b in blocks) {
    if (length(b) > 0L) gt[rownames(b), colnames(b)] <- b
  }
  gt
}


#' Internal: Genotype Block From One Allele Matrix Page
#'
#' @param result The `result` element of one `/allelematrix` response.
#'
#' @return A character matrix, the page's variants in rows and call sets in
#'   columns, holding its "Genotype"/"GT" data matrix (`NA` where absent).
#' @keywords internal
#' @noRd
allele_matrix_block <- function(result) {
  v_ids <- as.character(unlist(result$variantDbIds))
  cs_ids <- as.character(unlist(result$callSetDbIds))
  block <- matrix(
    NA_character_,
    nrow = length(v_ids), ncol = length(cs_ids),
    dimnames = list(v_ids, cs_ids)
  )

  for (dm in result$dataMatrices) {
    nm <- dm$dataMatrixName %||% ""
    ab <- dm$dataMatrixAbbreviation %||% ""
    if (nm == "Genotype" || ab == "GT") {
      rows <- seq_len(min(length(dm$dataMatrix), length(v_ids)))
      for (i in rows) {
        # A JSON null is a missing call. unlist() would drop it and shift
        # every later call one call set to the left, so map cell by cell.
        row <- vapply(dm$dataMatrix[[i]], function(cell) {
          if (length(cell) == 0L) NA_character_ else as.character(cell[[1L]])
        }, character(1))
        cols <- seq_len(min(length(row), length(cs_ids)))
        block[i, cols] <- row[cols]
      }
      break
    }
  }
  block
}


#' Search Variants
#'
#' @inheritParams brapi_shared_search
#' @param variantSetDbIds Character vector. Filter by variant set IDs.
#'
#' @return A tibble of matching variants.
#'
#' @section BrAPI endpoint:
#' `POST /search/variants` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/Variants/Search_Variants_POST.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_search_variants(con, variantSetDbIds = "variantset1")
#' }
#' }
#'
#' @export
brapi_search_variants <- function(con, variantSetDbIds = NULL, ...) {
  body <- compact(list(variantSetDbIds = variantSetDbIds, ...))
  brapi_post_search(con, "/search/variants", body = body)
}


#' Search Genotype Calls
#'
#' @inheritParams brapi_shared_search
#' @param variantSetDbIds Character vector. Filter by variant set IDs.
#' @param callSetDbIds Character vector. Filter by call set IDs.
#'
#' @return A tibble of matching genotype calls.
#'
#' @section BrAPI endpoint:
#' `POST /search/calls` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/Calls/Search_Calls_POST.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_search_calls(con, variantSetDbIds = "variantset1")
#' }
#' }
#'
#' @export
brapi_search_calls <- function(con, variantSetDbIds = NULL,
                               callSetDbIds = NULL, ...) {
  body <- compact(list(
    variantSetDbIds = variantSetDbIds,
    callSetDbIds    = callSetDbIds,
    ...
  ))
  brapi_post_search(con, "/search/calls", body = body)
}


#' Get Dosage Matrix for Genomic Selection
#'
#' Fetches genotype data from a BrAPI server and converts it into a numeric
#' dosage matrix (samples × markers) compatible with genomic selection
#' packages like `rrBLUP`, `BGLR`, and `sommer`.
#'
#' The server is asked for expanded homozygotes, `sep` as the unphased
#' separator and `unknown_string` for missing data. Allele dosage is then
#' computed by splitting each genotype string on `sep` (or `"|"` for phased
#' calls) and counting how many alleles are non-reference (i.e. not `"0"`).
#' A call with any missing allele (`unknown_string`, `"."` or `""`), such as
#' `"./1"`, becomes `NA`. A server that still collapses a homozygote to a
#' single allele (`"1"`) gets it expanded to the ploidy seen in the rest of
#' the data, or to 2 if every call is collapsed. Alleles must be numeric
#' indices (`"0"`, `"1"`, ...); nucleotide calls such as `"A/T"` are an
#' error.
#'
#' @inheritParams brapi_shared_params
#' @param variantSetDbId Character. The variant set to retrieve.
#' @param sep Character. Unphased allele separator. Default `"/"` (e.g.
#'   `"0/1"`). Phased calls using `"|"` are also handled automatically.
#' @param unknown_string Character. String representing missing data.
#'   Default `"."`.
#'
#' @return A numeric (double) matrix: rows = samples (callSetDbIds),
#'   columns = markers (variantDbIds). Values are whole-number dosages
#'   (0, 1, 2 for diploids; 0–N for polyploids). Missing calls are `NA`.
#'
#' @section BrAPI endpoint:
#' `GET /allelematrix` - see the
#' [v2.1 specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/AlleleMatrix/AlleleMatrix_GET.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   dosage <- brapi_get_dosage_matrix(con, "variantset1")
#'   dim(dosage)
#'   # Use with rrBLUP:
#'   # library(rrBLUP)
#'   # result <- mixed.solve(y = pheno$yield, Z = dosage)
#' }
#' }
#'
#' @export
brapi_get_dosage_matrix <- function(con, variantSetDbId,
                                    sep = "/", unknown_string = ".") {
  cli_alert_info(
    "Fetching allele matrix for variant set {.val {variantSetDbId}}..."
  )

  validate_con(con)
  # Variants in rows, call sets in columns.
  gt <- fetch_allele_matrix_pages(con, list(
    variantSetDbId = variantSetDbId,
    expandHomozygotes = "true",
    sepUnphased = sep,
    unknownString = unknown_string
  ))

  if (length(gt) == 0L) {
    cli_abort("No allele matrix data returned for {.val {variantSetDbId}}.")
  }

  cli_alert_info(
    "Encoding {length(gt)} genotype calls as allele dosages..."
  )

  # Each distinct genotype string is decoded once, then mapped back.
  calls <- unique(as.vector(gt))
  dosage <- genotype_dosages(calls, sep, unknown_string)
  mat <- matrix(
    dosage[match(t(gt), calls)],
    nrow = ncol(gt),
    dimnames = list(colnames(gt), rownames(gt))
  )

  cli_alert_success(
    "Dosage matrix ready: {nrow(mat)} samples x {ncol(mat)} markers."
  )
  mat
}


#' Internal: Allele Dosages for a Set of Genotype Strings
#'
#' @param calls Character vector of distinct genotype strings.
#' @param sep Character. Unphased allele separator; `"|"` is also accepted.
#' @param unknown_string Character. The server's missing-data string.
#'
#' @return A double vector the length of `calls`: the number of
#'   non-reference alleles in each, or `NA` for a call with any missing
#'   allele. A single-allele (collapsed homozygous) call is expanded to the
#'   most common ploidy among the multi-allele calls, or 2 if there are none.
#' @keywords internal
#' @noRd
genotype_dosages <- function(calls, sep, unknown_string) {
  missing_allele <- c(unknown_string, ".", "")
  alleles <- lapply(calls, function(call) {
    if (is.na(call) || call %in% missing_allele) {
      return(NULL)
    }
    a <- strsplit(call, sep, fixed = TRUE)[[1]]
    if (length(a) < 2L) {
      a <- strsplit(call, "|", fixed = TRUE)[[1]]
    }
    if (length(a) == 0L || any(a %in% missing_allele)) {
      return(NULL)
    }
    a
  })

  present <- !vapply(alleles, is.null, logical(1))
  bad <- calls[present][!vapply(alleles[present], function(a) {
    all(grepl("^[0-9]+$", a))
  }, logical(1))]
  if (length(bad)) {
    cli_abort(c(
      "Genotype calls must be numeric allele indices such as {.val 0/1}.",
      "x" = "Got {.val {utils::head(bad, 5)}}."
    ))
  }

  n_alleles <- lengths(alleles)
  multi <- n_alleles[n_alleles > 1L]
  ploidy <- if (length(multi)) {
    as.integer(names(which.max(table(multi))))
  } else {
    2L
  }

  vapply(alleles, function(a) {
    if (is.null(a)) {
      return(NA_real_)
    }
    if (length(a) == 1L) {
      return(if (a == "0") 0 else as.numeric(ploidy))
    }
    as.numeric(sum(a != "0"))
  }, numeric(1))
}


#' Get Marker Map
#'
#' Convenience function that retrieves marker positions on a genome map as
#' a tidy tibble. Positions come from the Genome Maps entity
#' ([brapi_marker_positions()] / `/markerpositions`), which places a
#' marker on a named [brapi_map()] - genetic (cM) or physical (bp), per
#' the map's `type` and `unit` - not from [brapi_variants()]'s
#' `start`/`referenceName`, which places a variant on a reference assembly
#' instead. A server may populate either, both, or neither; the two are
#' independent coordinate systems, not duplicates of each other.
#'
#' Supply exactly one of `mapDbId` (every marker placed on that one map)
#' or `variantSetDbId` (positions for every variant in that set, wherever
#' they have been placed). The `variantSetDbId` path looks variant IDs up
#' first via [brapi_variants()], then retrieves their positions in one
#' call via [brapi_search_marker_positions()] rather than the GET
#' `/markerpositions` filter, which only accepts a single `variantDbId`.
#'
#' If a marker is placed on more than one map, it contributes one row per
#' placement - the result is never collapsed to one row per marker.
#'
#' @inheritParams brapi_shared_params
#' @param variantSetDbId Character or NULL. A variant set to retrieve
#'   marker positions for. Mutually exclusive with `mapDbId`.
#' @param mapDbId Character or NULL. A single genome map to retrieve all
#'   marker positions from. Mutually exclusive with `variantSetDbId`.
#'
#' @return A tibble with columns `variantDbId`, `variantName`, `mapDbId`,
#'   `mapName`, `type`, `unit`, `linkageGroupName`, and `position` - one
#'   row per marker-map placement, so a marker on several maps appears
#'   more than once. `type` and `unit` are joined in from [brapi_maps()]
#'   so a caller can tell a genetic (cM) map from a physical (bp) one.
#'
#' @section BrAPI endpoints:
#' With `mapDbId`: `GET /markerpositions`. With `variantSetDbId`:
#' `GET /variants`, then `POST /search/markerpositions`. Either way,
#' `GET /maps` for the map metadata. See the v2.1 specification for
#' [`/markerpositions`](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/GenomeMaps/MarkerPositions_GET.yaml),
#' [`/variants`](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/Variants/Variants_GET.yaml),
#' [`/search/markerpositions`](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/GenomeMaps/Search_MarkerPositions_POST.yaml)
#' and [`/maps`](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/GenomeMaps/Maps_GET.yaml).
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' if (brapi_ping(con)) {
#'   brapi_get_marker_map(con, mapDbId = "genome_map1")
#'   brapi_get_marker_map(con, variantSetDbId = "variantset1")
#' }
#' }
#'
#' @export
brapi_get_marker_map <- function(con, variantSetDbId = NULL, mapDbId = NULL) {
  if (is.null(variantSetDbId) && is.null(mapDbId)) {
    cli_abort(c(
      "Supply exactly one of {.arg variantSetDbId} or {.arg mapDbId}.",
      "i" = "Neither was supplied."
    ))
  }
  if (!is.null(variantSetDbId) && !is.null(mapDbId)) {
    cli_abort(c(
      "Supply exactly one of {.arg variantSetDbId} or {.arg mapDbId}.",
      "i" = "Both were supplied; only one identifier is allowed at a time."
    ))
  }

  if (!is.null(mapDbId)) {
    positions <- brapi_marker_positions(con, mapDbId = mapDbId)
    if (nrow(positions) == 0L) {
      cli_warn("No marker positions found for map {.val {mapDbId}}.")
      return(empty_marker_map())
    }
  } else {
    variants <- brapi_variants(con, variantSetDbId = variantSetDbId)
    if (nrow(variants) == 0L) {
      cli_warn("No variants found for {.val {variantSetDbId}}.")
      return(empty_marker_map())
    }

    variant_ids <- unique(variants$variantDbId)
    positions <- brapi_search_marker_positions(con, variantDbIds = variant_ids)
    n_found <- if (nrow(positions) == 0L) {
      0L
    } else {
      length(unique(positions$variantDbId))
    }

    if (n_found < length(variant_ids)) {
      cli_warn(paste0(
        "{length(variant_ids) - n_found} of {length(variant_ids)} ",
        "variants in {.val {variantSetDbId}} have no marker position ",
        "record; returning positions for the remaining {n_found}."
      ))
    }

    if (nrow(positions) == 0L) {
      return(empty_marker_map())
    }
  }

  # Join in mapName/type/unit from the Genome Maps entity rather than
  # trusting /markerpositions' own (spec-optional) mapName field.
  map_ids <- unique(positions$mapDbId)
  all_maps <- brapi_maps(con)
  meta_cols <- intersect(
    c("mapDbId", "mapName", "type", "unit"), names(all_maps)
  )
  map_meta <- all_maps[all_maps$mapDbId %in% map_ids, meta_cols, drop = FALSE]

  positions$mapName <- NULL
  result <- dplyr::left_join(positions, map_meta, by = "mapDbId")

  cols <- intersect(
    c("variantDbId", "variantName", "mapDbId", "mapName", "type", "unit",
      "linkageGroupName", "position"),
    names(result)
  )
  result[, cols, drop = FALSE]
}


#' Internal: Empty Marker-Map Result Tibble
#'
#' @return A zero-row tibble with [brapi_get_marker_map()]'s column set.
#' @keywords internal
#' @noRd
empty_marker_map <- function() {
  tibble(
    variantDbId      = character(),
    variantName      = character(),
    mapDbId          = character(),
    mapName          = character(),
    type             = character(),
    unit             = character(),
    linkageGroupName = character(),
    position         = integer()
  )
}
