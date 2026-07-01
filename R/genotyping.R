# ---- BrAPI Genotyping Module ----
# Endpoints: /samples, /variants, /variantsets, /calls, /callsets,
#            /references, /referencesets, /allelematrix, /vendor/orders


#' List Samples
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters
#'   (e.g. `studyDbId`, `germplasmDbId`, `observationUnitDbId`).
#'
#' @return A tibble with one row per sample.
#'
#' @export
brapi_samples <- function(con, ...) {
  brapi_get(con, "/samples", query = list(...))
}


#' List Variants (Markers/SNPs)
#'
#' @param con A [brapi_connection()] object.
#' @param variantSetDbId Character or NULL. Filter by variant set.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per variant.
#'
#' @export
brapi_variants <- function(con, variantSetDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(variantSetDbId)) query$variantSetDbId <- variantSetDbId
  brapi_get(con, "/variants", query = query)
}


#' List Variant Sets (Datasets)
#'
#' @param con A [brapi_connection()] object.
#' @param studyDbId Character or NULL. Filter by study.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per variant set.
#'
#' @export
brapi_variant_sets <- function(con, studyDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(studyDbId)) query$studyDbId <- studyDbId
  brapi_get(con, "/variantsets", query = query)
}


#' List Genotype Calls
#'
#' @param con A [brapi_connection()] object.
#' @param variantSetDbId Character or NULL. Filter by variant set.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per genotype call.
#'
#' @export
brapi_calls <- function(con, variantSetDbId = NULL, ...) {
  query <- list(...)
  if (!is.null(variantSetDbId)) query$variantSetDbId <- variantSetDbId
  brapi_get(con, "/calls", query = query)
}


#' List Call Sets (Samples with Genotype Data)
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per call set.
#'
#' @export
brapi_call_sets <- function(con, ...) {
  brapi_get(con, "/callsets", query = list(...))
}


#' List References (Chromosomes/Contigs)
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per reference sequence.
#'
#' @export
brapi_references <- function(con, ...) {
  brapi_get(con, "/references", query = list(...))
}


#' List Reference Sets (Genome Assemblies)
#'
#' @param con A [brapi_connection()] object.
#' @param ... Additional query parameters.
#'
#' @return A tibble with one row per reference set.
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
#' @param con A [brapi_connection()] object.
#' @param variantSetDbId Character or NULL. Filter by variant set.
#' @param ... Additional query parameters
#'   (e.g. `expandHomozygotes`, `unknownString`, `sepPhased`, `sepUnphased`).
#'
#' @return A tibble with columns `variantDbId`, `callSetDbId`, `genotype`.
#'
#' @export
brapi_allele_matrix <- function(con, variantSetDbId = NULL, ...) {
  validate_con(con)

  query <- list(...)
  if (!is.null(variantSetDbId)) query$variantSetDbId <- variantSetDbId
  query$pageSize <- query$pageSize %||% con$page_size

  cs_page <- 0L
  cs_total_pages <- 1L

  all_variant_ids <- character(0)
  all_callset_ids <- character(0)
  # gt_mat[i] will hold all genotype strings for variant i across callset pages
  gt_mat <- list()

  repeat {
    query$callSetPage <- cs_page

    resp <- brapi_req(con, "/allelematrix") |>
      req_url_query(!!!query) |>
      req_perform()

    body <- resp_body_json(resp, simplifyVector = FALSE)

    # /allelematrix uses an array of pagination objects, one per dimension
    for (p in body$result$pagination) {
      if (identical(p$dimension, "CALLSETS")) {
        cs_total_pages <- p$totalPages %||% 1L
      }
    }

    cs_ids <- unlist(body$result$callSetDbIds)
    v_ids <- unlist(body$result$variantDbIds)

    if (cs_page == 0L) {
      all_variant_ids <- v_ids
      gt_mat <- vector("list", length(v_ids))
    }
    all_callset_ids <- c(all_callset_ids, cs_ids)

    # Find the Genotype data matrix
    for (dm in body$result$dataMatrices) {
      nm <- dm$dataMatrixName %||% ""
      ab <- dm$dataMatrixAbbreviation %||% ""
      if (nm == "Genotype" || ab == "GT") {
        for (i in seq_along(dm$dataMatrix)) {
          gt_mat[[i]] <- c(gt_mat[[i]], unlist(dm$dataMatrix[[i]]))
        }
        break
      }
    }

    cs_page <- cs_page + 1L
    if (cs_page >= cs_total_pages) break
  }

  n_v <- length(all_variant_ids)
  n_cs <- length(all_callset_ids)

  if (n_v == 0L || n_cs == 0L) {
    return(tibble())
  }

  tibble(
    variantDbId = rep(all_variant_ids, each = n_cs),
    callSetDbId = rep(all_callset_ids, times = n_v),
    genotype    = unlist(lapply(gt_mat, function(row) row[seq_len(n_cs)]))
  )
}


#' Search Variants
#'
#' @param con A [brapi_connection()] object.
#' @param variantSetDbIds Character vector. Filter by variant set IDs.
#' @param ... Additional search body parameters.
#'
#' @return A tibble of matching variants.
#'
#' @export
brapi_search_variants <- function(con, variantSetDbIds = NULL, ...) {
  body <- compact(list(variantSetDbIds = variantSetDbIds, ...))
  brapi_post_search(con, "/search/variants", body = body)
}


#' Search Genotype Calls
#'
#' @param con A [brapi_connection()] object.
#' @param variantSetDbIds Character vector. Filter by variant set IDs.
#' @param callSetDbIds Character vector. Filter by call set IDs.
#' @param ... Additional search body parameters.
#'
#' @return A tibble of matching genotype calls.
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
#' Allele dosage is computed by splitting each genotype string on `sep` (or
#' `"|"` for phased calls) and counting how many alleles are non-reference
#' (i.e. not `"0"`). Missing calls (`unknown_string`, `"."`, or `""`) become
#' `NA`.
#'
#' @param con A [brapi_connection()] object.
#' @param variantSetDbId Character. The variant set to retrieve.
#' @param sep Character. Unphased allele separator. Default `"/"` (e.g.
#'   `"0/1"`). Phased calls using `"|"` are also handled automatically.
#' @param unknown_string Character. String representing missing data.
#'   Default `"."`.
#'
#' @return A numeric matrix: rows = samples (callSetDbIds), columns = markers
#'   (variantDbIds). Values are integer dosages (0, 1, 2 for diploids; 0–N
#'   for polyploids). Missing calls are `NA`.
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' dosage <- brapi_get_dosage_matrix(con, "variantset_01")
#' dim(dosage)
#' # Use with rrBLUP:
#' # library(rrBLUP)
#' # result <- mixed.solve(y = pheno$yield, Z = dosage)
#' }
#'
#' @export
brapi_get_dosage_matrix <- function(con, variantSetDbId,
                                    sep = "/", unknown_string = ".") {
  cli_alert_info(
    "Fetching allele matrix for variant set {.val {variantSetDbId}}..."
  )

  tidy <- brapi_allele_matrix(con, variantSetDbId = variantSetDbId)

  if (nrow(tidy) == 0L) {
    cli_abort("No allele matrix data returned for {.val {variantSetDbId}}.")
  }

  cli_alert_info(
    "Encoding {nrow(tidy)} genotype calls as allele dosages..."
  )

  geno_to_dosage <- function(geno) {
    if (is.na(geno) || geno == unknown_string ||
      geno == "." || geno == "") {
      return(NA_real_)
    }
    alleles <- strsplit(geno, sep, fixed = TRUE)[[1]]
    # Fall back to phased separator
    if (length(alleles) < 2L) {
      alleles <- strsplit(geno, "|", fixed = TRUE)[[1]]
    }
    if (length(alleles) < 2L) {
      return(NA_real_)
    }
    # Count non-reference alleles (anything other than "0")
    sum(alleles != "0", na.rm = TRUE)
  }

  tidy$dosage <- vapply(tidy$genotype, geno_to_dosage, numeric(1L))

  # Pivot to wide: rows = samples (callSets), cols = markers (variants)
  wide <- pivot_wider(
    tidy[, c("callSetDbId", "variantDbId", "dosage")],
    names_from  = "variantDbId",
    values_from = "dosage"
  )

  sample_ids <- wide$callSetDbId
  mat <- as.matrix(wide[, -1L, drop = FALSE])
  rownames(mat) <- sample_ids

  cli_alert_success(
    "Dosage matrix ready: {nrow(mat)} samples x {ncol(mat)} markers."
  )
  mat
}


#' Get Marker Map
#'
#' Convenience function that retrieves variant positions as a tidy tibble
#' with columns for marker name, chromosome, and position.
#'
#' @param con A [brapi_connection()] object.
#' @param variantSetDbId Character. The variant set to retrieve markers from.
#'
#' @return A tibble with columns: `variantDbId`, `variantName`,
#'   `referenceName` (chromosome), `start` (position in bp).
#'
#' @examples
#' \dontrun{
#' con <- brapi_connection("https://test-server.brapi.org")
#' markers <- brapi_get_marker_map(con, "variantset_01")
#' head(markers)
#' }
#'
#' @export
brapi_get_marker_map <- function(con, variantSetDbId) {
  variants <- brapi_variants(con, variantSetDbId = variantSetDbId)

  if (nrow(variants) == 0) {
    cli_alert_warning("No variants found for {.val {variantSetDbId}}.")
    return(tibble(
      variantDbId   = character(),
      variantName   = character(),
      referenceName = character(),
      start         = integer()
    ))
  }

  # Select key columns; handle both variantName (scalar) and variantNames
  # (list-column) depending on the server's response format.
  cols <- intersect(
    c("variantDbId", "variantName", "variantNames", "referenceName", "start"),
    names(variants)
  )
  result <- variants[, cols, drop = FALSE]

  if ("variantNames" %in% names(result) && !"variantName" %in% names(result)) {
    result$variantName <- vapply(
      result$variantNames,
      function(x) {
        x <- unlist(x)
        if (length(x) > 0L) as.character(x[[1L]]) else NA_character_
      },
      character(1L)
    )
    result$variantNames <- NULL
  }

  result[, intersect(
    c("variantDbId", "variantName", "referenceName", "start"),
    names(result)
  ), drop = FALSE]
}
