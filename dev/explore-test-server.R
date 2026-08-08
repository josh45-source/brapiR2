# Exploratory script: does the public BrAPI test server hold enough data
# to support an evaluated genomic selection article?
#
# Not run as part of R CMD check or the test suite. Run interactively with:
#   Rscript dev/explore-test-server.R
#
# Answers, in order:
#   1. Phenotype side  - studies, observation units/observations, variables
#   2. Genotype side   - variant sets, variants, call sets, dosage matrix
#   3. Overlap         - how many germplasm have BOTH phenotype and genotype data
#   4. Verdict         - paired germplasm count, marker count, trait variance

library(brapiR2)
suppressPackageStartupMessages({
  library(dplyr)
})

SERVER <- "https://test-server.brapi.org"

section <- function(title) {
  cat("\n", strrep("=", 70), "\n", sep = "")
  cat(title, "\n")
  cat(strrep("=", 70), "\n", sep = "")
}

safely <- function(expr, label) {
  tryCatch(
    expr,
    error = function(e) {
      cat(sprintf("  [ERROR] %s: %s\n", label, conditionMessage(e)))
      NULL
    }
  )
}

con <- brapi_connection(SERVER)

section("CONNECTIVITY")
reachable <- safely(brapi_ping(con), "brapi_ping")
if (!isTRUE(reachable)) {
  cat("Server is not reachable. Aborting exploration.\n")
  quit(save = "no", status = 1L)
}

## ------------------------------------------------------------------------
## 1. PHENOTYPE SIDE
## ------------------------------------------------------------------------
section("1. PHENOTYPE SIDE")

studies <- safely(brapi_studies(con), "brapi_studies")
n_studies <- if (is.null(studies)) 0L else nrow(studies)
cat(sprintf("Studies available: %d\n", n_studies))

study_summary <- NULL
if (n_studies > 0L) {
  n_preview <- min(5L, n_studies)
  cat(sprintf("\nInspecting the first %d studies:\n", n_preview))

  study_summary <- lapply(seq_len(n_preview), function(i) {
    sid <- studies$studyDbId[i]
    sname <- if ("studyName" %in% names(studies)) studies$studyName[i] else NA_character_

    ou <- safely(brapi_observation_units(con, studyDbId = sid), "brapi_observation_units")
    obs <- safely(brapi_observations(con, studyDbId = sid), "brapi_observations")

    n_ou <- if (is.null(ou)) NA_integer_ else nrow(ou)
    n_obs <- if (is.null(obs)) NA_integer_ else nrow(obs)

    cat(sprintf(
      "  - %s (%s): %s observation units, %s observations\n",
      sid, if (is.null(sname) || is.na(sname)) "?" else sname,
      ifelse(is.na(n_ou), "ERROR", n_ou),
      ifelse(is.na(n_obs), "ERROR", n_obs)
    ))

    tibble(studyDbId = sid, studyName = sname, n_ou = n_ou, n_obs = n_obs)
  })
  study_summary <- bind_rows(study_summary)
}

vars <- safely(brapi_observation_variables(con), "brapi_observation_variables")
n_vars <- if (is.null(vars)) 0L else nrow(vars)
cat(sprintf("\nObservation variables defined on server: %d\n", n_vars))
if (n_vars > 0L) {
  name_col <- intersect(c("observationVariableName", "name"), names(vars))[1]
  if (!is.na(name_col) && !is.null(name_col)) {
    cat("Examples:", paste(utils::head(vars[[name_col]], 10), collapse = ", "), "\n")
  }
}

best_study_id <- NULL
study_data <- NULL
n_germplasm_pheno <- 0L
germplasm_pheno_ids <- character(0)

# IMPORTANT: this server does not reliably implement the studyDbId filter on
# the raw /observations endpoint, so study_summary$n_obs (from
# brapi_observations(con, studyDbId = sid) above) reads as 0 even for
# studies that do have data. brapi_study_data() has its own fallback for
# exactly this case (it retries unfiltered and filters client-side), so we
# call it for every previewed study directly rather than gating on n_obs.
if (!is.null(study_summary) && nrow(study_summary) > 0L) {
  all_study_data <- lapply(study_summary$studyDbId, function(sid) {
    safely(brapi_study_data(con, sid), sprintf("brapi_study_data(%s)", sid))
  })
  names(all_study_data) <- study_summary$studyDbId

  for (sid in names(all_study_data)) {
    d <- all_study_data[[sid]]
    n_rows <- if (is.null(d)) NA_integer_ else nrow(d)
    cat(sprintf(
      "brapi_study_data(%s): %s rows\n", sid, ifelse(is.na(n_rows), "ERROR", n_rows)
    ))
  }

  row_counts <- vapply(
    all_study_data,
    function(d) if (is.null(d)) 0L else nrow(d),
    integer(1)
  )

  if (any(row_counts > 0L)) {
    best_study_id <- names(all_study_data)[which.max(row_counts)]
    study_data <- all_study_data[[best_study_id]]
    cat(sprintf(
      "\nStudy with the most observations (via brapi_study_data()): %s\n",
      best_study_id
    ))
    cat(sprintf("brapi_study_data() dimensions: %d rows x %d columns\n",
                nrow(study_data), ncol(study_data)))
    cat("Column names:", paste(names(study_data), collapse = ", "), "\n")

    id_cols <- c(
      "observationUnitDbId", "observationUnitName",
      "germplasmDbId", "germplasmName", "studyDbId", "studyName"
    )
    trait_cols <- setdiff(names(study_data), id_cols)
    if (length(trait_cols) > 0L) {
      cat("\nTrait column types:\n")
      for (tc in trait_cols) {
        cat(sprintf("  - %-30s %s\n", tc, class(study_data[[tc]])[1]))
      }
    } else {
      cat("No trait columns identified beyond ID columns.\n")
    }

    # Collect germplasm across ALL studies with data, not just the best one,
    # since the overlap question in Part 3 needs the full phenotype-side set.
    for (d in all_study_data) {
      if (!is.null(d) && nrow(d) > 0L && "germplasmDbId" %in% names(d)) {
        germplasm_pheno_ids <- c(germplasm_pheno_ids, unique(d$germplasmDbId))
      }
    }
    germplasm_pheno_ids <- unique(stats::na.omit(germplasm_pheno_ids))
    n_germplasm_pheno <- length(germplasm_pheno_ids)
    cat(sprintf(
      "\nDistinct germplasm with phenotype data (across all studies): %d\n",
      n_germplasm_pheno
    ))
  } else {
    cat("\nbrapi_study_data() returned no rows for any previewed study.\n")
  }
} else {
  cat("\nNo studies available; skipping brapi_study_data().\n")
}

## ------------------------------------------------------------------------
## 2. GENOTYPE SIDE
## ------------------------------------------------------------------------
section("2. GENOTYPE SIDE")

variant_sets <- safely(brapi_variant_sets(con), "brapi_variant_sets")
n_vs <- if (is.null(variant_sets)) 0L else nrow(variant_sets)
cat(sprintf("Variant sets available: %d\n", n_vs))

dosage <- NULL
callset_ids_geno <- character(0)
sample_ids_geno <- character(0)
largest_vs_id <- NULL

if (n_vs > 0L) {
  # "Largest" by variant count where the server reports it; otherwise fall
  # back to the first variant set and note the assumption.
  size_col <- intersect(c("variantCount", "callSetCount"), names(variant_sets))
  if (length(size_col) > 0L) {
    largest_vs_id <- variant_sets$variantSetDbId[which.max(variant_sets[[size_col[1]]])]
    cat(sprintf("Largest variant set (by %s): %s\n", size_col[1], largest_vs_id))
  } else {
    largest_vs_id <- variant_sets$variantSetDbId[1]
    cat(sprintf("Server does not report set sizes; using first variant set: %s\n", largest_vs_id))
  }

  variants <- safely(brapi_variants(con, variantSetDbId = largest_vs_id), "brapi_variants")
  n_variants <- if (is.null(variants)) NA_integer_ else nrow(variants)
  cat(sprintf("Variants in %s: %s\n", largest_vs_id, ifelse(is.na(n_variants), "ERROR", n_variants)))

  call_sets <- safely(brapi_call_sets(con, variantSetDbId = largest_vs_id), "brapi_call_sets")
  n_callsets <- if (is.null(call_sets)) NA_integer_ else nrow(call_sets)
  cat(sprintf("Call sets in %s: %s\n", largest_vs_id, ifelse(is.na(n_callsets), "ERROR", n_callsets)))

  if (!is.null(call_sets) && nrow(call_sets) > 0L && "callSetDbId" %in% names(call_sets)) {
    callset_ids_geno <- unique(call_sets$callSetDbId)
  }
  sample_ids_geno <- if (!is.null(call_sets) && "sampleDbId" %in% names(call_sets)) {
    unique(stats::na.omit(call_sets$sampleDbId))
  } else {
    character(0)
  }

  dosage <- safely(brapi_get_dosage_matrix(con, largest_vs_id), "brapi_get_dosage_matrix")
  if (!is.null(dosage) && length(dosage) > 0L) {
    cat(sprintf("\nDosage matrix dimensions: %d samples x %d markers\n",
                nrow(dosage), ncol(dosage)))
    rng <- range(dosage, na.rm = TRUE)
    cat(sprintf("Dosage value range: [%s, %s]\n", rng[1], rng[2]))
    prop_na <- mean(is.na(dosage))
    cat(sprintf("Proportion missing: %.1f%%\n", 100 * prop_na))

    if (length(callset_ids_geno) == 0L) {
      callset_ids_geno <- unique(rownames(dosage))
    }
  } else {
    cat("brapi_get_dosage_matrix() returned no data.\n")
  }
} else {
  cat("No variant sets available; skipping variant/call-set/dosage exploration.\n")
}

## ------------------------------------------------------------------------
## 3. THE CRITICAL QUESTION - OVERLAP
## ------------------------------------------------------------------------
section("3. OVERLAP BETWEEN PHENOTYPE AND GENOTYPE GERMPLASM")

germplasm_geno_ids <- character(0)

# call_sets does NOT carry germplasmDbId directly on this server - it only
# has sampleDbId. Resolve germplasm via brapi_samples(), joining on
# sampleDbId (NOT callSetDbId - callset IDs and sample IDs are different
# ID spaces here, e.g. "callset01" vs "sample1", so comparing them directly
# silently resolves nothing).
if (length(sample_ids_geno) > 0L) {
  samples <- safely(brapi_samples(con), "brapi_samples")
  if (!is.null(samples) && "germplasmDbId" %in% names(samples) &&
        "sampleDbId" %in% names(samples)) {
    resolved <- samples |>
      filter(.data$sampleDbId %in% sample_ids_geno) |>
      pull(.data$germplasmDbId)
    germplasm_geno_ids <- unique(stats::na.omit(resolved))
    cat(sprintf(
      "Resolved %d/%d call sets to germplasmDbId via brapi_samples() (joined on sampleDbId).\n",
      length(germplasm_geno_ids), length(sample_ids_geno)
    ))
  } else {
    cat("brapi_samples() does not expose sampleDbId/germplasmDbId on this server; ")
    cat("cannot resolve genotype records to germplasm.\n")
  }
} else {
  cat("No call set / sample identifiers available from the genotype side.\n")
}

overlap_ids <- intersect(germplasm_pheno_ids, germplasm_geno_ids)

cat(sprintf("\nGermplasm with phenotype data:            %d\n", length(germplasm_pheno_ids)))
cat(sprintf("Germplasm with genotype data (resolved):  %d\n", length(germplasm_geno_ids)))
cat(sprintf("Germplasm with BOTH phenotype and genotype data: %d\n", length(overlap_ids)))

## ------------------------------------------------------------------------
## 4. VERDICT
## ------------------------------------------------------------------------
section("4. VERDICT")

n_markers <- if (!is.null(dosage) && length(dosage) > 0L) ncol(dosage) else 0L

trait_has_variance <- FALSE
trait_variance_detail <- "no trait columns available"
if (!is.null(study_data) && nrow(study_data) > 0L) {
  id_cols <- c(
    "observationUnitDbId", "observationUnitName",
    "germplasmDbId", "germplasmName", "studyDbId", "studyName"
  )
  trait_cols <- setdiff(names(study_data), id_cols)
  numeric_trait_cols <- trait_cols[vapply(
    trait_cols,
    function(tc) {
      v <- suppressWarnings(as.numeric(unlist(study_data[[tc]])))
      length(stats::na.omit(v)) > 1L
    },
    logical(1)
  )]
  if (length(numeric_trait_cols) > 0L) {
    variances <- vapply(
      numeric_trait_cols,
      function(tc) stats::var(suppressWarnings(as.numeric(unlist(study_data[[tc]]))), na.rm = TRUE),
      numeric(1)
    )
    trait_has_variance <- any(variances > 0, na.rm = TRUE)
    trait_variance_detail <- paste(
      sprintf("%s (var=%.4g)", names(variances), variances),
      collapse = "; "
    )
  }
}

cat(sprintf("Germplasm with paired phenotype + genotype data: %d\n", length(overlap_ids)))
cat(sprintf("Markers available for those germplasm:            %d\n", n_markers))
cat(sprintf("Trait values show variance:                       %s\n",
            ifelse(trait_has_variance, "YES", "NO")))
cat(sprintf("  (%s)\n", trait_variance_detail))

# Genomic prediction needs enough individuals to estimate marker effects and
# to hold some out for validation. There's no universal minimum, but fewer
# than ~20 paired records is not enough for a meaningful demonstration
# (let alone a defensible cross-validation split), regardless of whether
# markers or trait variance are present.
min_useful_n <- 20L

cat("\n")
if (length(overlap_ids) >= min_useful_n && n_markers > 0L && trait_has_variance) {
  cat("VERDICT: The test server appears to hold ENOUGH paired data to support\n")
  cat("an evaluated genomic selection article (eval = TRUE against the live server).\n")
} else if (length(overlap_ids) > 0L) {
  cat(sprintf(
    "VERDICT: The test server DOES pair phenotype and genotype data for %d\n",
    length(overlap_ids)
  ))
  cat(sprintf(
    "germplasm, but that is far short of the ~%d+ typically needed for a\n",
    min_useful_n
  ))
  cat("meaningful genomic prediction demonstration (e.g. any train/test split).\n")
  cat("Retrieval calls can and should evaluate live against this data; the\n")
  cat("modelling step still needs a simulated dataset.\n")
} else {
  cat("VERDICT: The test server does NOT appear to hold any paired phenotype +\n")
  cat("genotype data (or trait values lack variance) to support an evaluated\n")
  cat("genomic selection article. Prefer a synthetic dataset for that vignette.\n")
}
