## brapiR2 - Live server integration tests
## Target: https://test-server.brapi.org
## Run interactively; NOT part of the automated test suite.
##
## Usage: run this file interactively, or step through it line by line
## in RStudio.

library(brapiR2)
library(dplyr, warn.conflicts = FALSE)

SERVER <- "https://test-server.brapi.org"

cat("\n==============================\n")
cat("SECTION 1: CORE MODULE\n")
cat("==============================\n\n")

con <- brapi_connection(SERVER)
print(con)

# ---- 1.1  Ping ----
cat("\n--- brapi_ping ---\n")
ok <- brapi_ping(con)
stopifnot(isTRUE(ok))
cat("PASS: ping returned TRUE\n")

# ---- 1.2  Server info ----
cat("\n--- brapi_server_info ---\n")
info <- brapi_server_info(con)
cat("Class:", class(info), "\n")
cat("Dimensions:", nrow(info), "x", ncol(info), "\n")
cat("Names:", paste0(names(info), collapse = ", "), "\n")
str(info, max.level = 1)

# ---- 1.3  Programs ----
cat("\n--- brapi_programs ---\n")
progs <- brapi_programs(con)
cat("Class:", class(progs), "\n")
cat("Rows:", nrow(progs), "  Cols:", ncol(progs), "\n")
cat("Names:", paste0(names(progs), collapse = ", "), "\n")
stopifnot(inherits(progs, "data.frame"), nrow(progs) > 0)
cat("PASS: programs returned rows\n")
print(head(progs, 3))

# save a programDbId for later
prog_id <- progs$programDbId[1]
cat("Using programDbId:", prog_id, "\n")

# ---- 1.4  Trials ----
cat("\n--- brapi_trials ---\n")
trials <- brapi_trials(con)
cat("Rows:", nrow(trials), "  Cols:", ncol(trials), "\n")
cat("Names:", paste0(names(trials), collapse = ", "), "\n")
stopifnot(inherits(trials, "data.frame"), nrow(trials) > 0)
cat("PASS: trials returned rows\n")

trial_id <- trials$trialDbId[1]
cat("Using trialDbId:", trial_id, "\n")

# ---- 1.5  Studies ----
cat("\n--- brapi_studies ---\n")
studies <- brapi_studies(con)
cat("Rows:", nrow(studies), "  Cols:", ncol(studies), "\n")
cat("Names:", paste0(names(studies), collapse = ", "), "\n")
stopifnot(inherits(studies, "data.frame"), nrow(studies) > 0)
cat("PASS: studies returned rows\n")

study_id <- studies$studyDbId[1]
cat("Using studyDbId:", study_id, "\n")

# ---- 1.6  Locations ----
cat("\n--- brapi_locations ---\n")
locs <- brapi_locations(con)
cat("Rows:", nrow(locs), "  Cols:", ncol(locs), "\n")
stopifnot(inherits(locs, "data.frame"))
cat("PASS: locations returned\n")

# ---- 1.7  Seasons ----
cat("\n--- brapi_seasons ---\n")
seasons <- brapi_seasons(con)
cat("Rows:", nrow(seasons), "  Cols:", ncol(seasons), "\n")
stopifnot(inherits(seasons, "data.frame"))
cat("PASS: seasons returned\n")

cat("\n==============================\n")
cat("SECTION 2: GERMPLASM MODULE\n")
cat("==============================\n\n")

# ---- 2.1  List germplasm ----
cat("\n--- brapi_germplasm ---\n")
germ <- brapi_germplasm(con)
cat("Rows:", nrow(germ), "  Cols:", ncol(germ), "\n")
cat("Names:", paste0(names(germ), collapse = ", "), "\n")
stopifnot(inherits(germ, "data.frame"), nrow(germ) > 0)
cat("PASS: germplasm returned rows\n")

germ_id <- germ$germplasmDbId[1]
cat("Using germplasmDbId:", germ_id, "\n")

# ---- 2.2  Germplasm detail ----
cat("\n--- brapi_germplasm_detail ---\n")
gd <- brapi_germplasm_detail(con, germ_id)
cat("Rows:", nrow(gd), "  Cols:", ncol(gd), "\n")
stopifnot(inherits(gd, "data.frame"), nrow(gd) >= 1)
cat("PASS: germplasm detail returned\n")

# ---- 2.3  Pedigree ----
cat("\n--- brapi_germplasm_pedigree ---\n")
ped <- tryCatch(
  brapi_germplasm_pedigree(con, germ_id),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(ped)) {
  cat("Rows:", nrow(ped), "  Cols:", ncol(ped), "\n")
  cat("PASS: pedigree returned\n")
}

# ---- 2.4  Progeny ----
cat("\n--- brapi_germplasm_progeny ---\n")
prog <- tryCatch(
  brapi_germplasm_progeny(con, germ_id),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(prog)) {
  cat("Rows:", nrow(prog), "  Cols:", ncol(prog), "\n")
  cat("PASS: progeny returned\n")
}

# ---- 2.5  Search germplasm ----
cat("\n--- brapi_search_germplasm ---\n")
sg <- tryCatch(
  brapi_search_germplasm(con, germplasmNames = "Tribe_01"),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(sg)) {
  cat("Rows:", nrow(sg), "  Cols:", ncol(sg), "\n")
  cat("PASS: search germplasm returned\n")
  print(head(sg, 3))
}

cat("\n==============================\n")
cat("SECTION 3: PHENOTYPING MODULE\n")
cat("==============================\n\n")

# ---- 3.1  Observation units ----
cat("\n--- brapi_observation_units ---\n")
ou <- brapi_observation_units(con)
cat("Rows:", nrow(ou), "  Cols:", ncol(ou), "\n")
cat("Names:", paste0(names(ou), collapse = ", "), "\n")
stopifnot(inherits(ou, "data.frame"), nrow(ou) > 0)
cat("PASS: observation units returned\n")

# pick a studyDbId that has observations
if ("studyDbId" %in% names(ou)) {
  pheno_study_id <- ou$studyDbId[1]
  cat("Using studyDbId for phenotyping:", pheno_study_id, "\n")
} else {
  pheno_study_id <- study_id
}

# ---- 3.2  Observations ----
cat("\n--- brapi_observations ---\n")
obs <- brapi_observations(con, studyDbId = pheno_study_id)
cat("Rows:", nrow(obs), "  Cols:", ncol(obs), "\n")
cat("Names:", paste0(names(obs), collapse = ", "), "\n")
stopifnot(inherits(obs, "data.frame"))
if (nrow(obs) > 0) {
  cat("PASS: observations returned\n")
  print(head(obs, 3))
} else {
  cat("NOTE: no observations for this study, trying all\n")
  obs <- brapi_observations(con)
  cat("All observations - Rows:", nrow(obs), "\n")
}

# ---- 3.3  Observation variables ----
cat("\n--- brapi_observation_variables ---\n")
vars <- brapi_observation_variables(con)
cat("Rows:", nrow(vars), "  Cols:", ncol(vars), "\n")
cat("Names:", paste0(names(vars), collapse = ", "), "\n")
stopifnot(inherits(vars, "data.frame"), nrow(vars) > 0)
cat("PASS: observation variables returned\n")

# ---- 3.4  Study data (wide format) ----
cat("\n--- brapi_study_data ---\n")
# find a study that has observations
if (nrow(obs) > 0 && "studyDbId" %in% names(obs)) {
  sd_study_id <- obs$studyDbId[1]
} else {
  sd_study_id <- pheno_study_id
}
cat("Using studyDbId:", sd_study_id, "\n")

sd <- tryCatch(
  brapi_study_data(con, sd_study_id),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(sd)) {
  cat("Rows:", nrow(sd), "  Cols:", ncol(sd), "\n")
  cat("Names:", paste0(names(sd), collapse = ", "), "\n")
  cat("PASS: study data (wide) returned\n")
  print(head(sd, 3))
}

cat("\n==============================\n")
cat("SECTION 4: GENOTYPING MODULE\n")
cat("==============================\n\n")

# ---- 4.1  Variant sets ----
cat("\n--- brapi_variant_sets ---\n")
vs <- brapi_variant_sets(con)
cat("Rows:", nrow(vs), "  Cols:", ncol(vs), "\n")
cat("Names:", paste0(names(vs), collapse = ", "), "\n")
stopifnot(inherits(vs, "data.frame"), nrow(vs) > 0)
cat("PASS: variant sets returned\n")

vs_id <- vs$variantSetDbId[1]
cat("Using variantSetDbId:", vs_id, "\n")

# ---- 4.2  Variants ----
cat("\n--- brapi_variants ---\n")
variants <- brapi_variants(con, variantSetDbId = vs_id)
cat("Rows:", nrow(variants), "  Cols:", ncol(variants), "\n")
cat("Names:", paste0(names(variants), collapse = ", "), "\n")
stopifnot(inherits(variants, "data.frame"), nrow(variants) > 0)
cat("PASS: variants returned\n")

# ---- 4.3  Call sets ----
cat("\n--- brapi_call_sets ---\n")
cs <- brapi_call_sets(con)
cat("Rows:", nrow(cs), "  Cols:", ncol(cs), "\n")
cat("Names:", paste0(names(cs), collapse = ", "), "\n")
stopifnot(inherits(cs, "data.frame"), nrow(cs) > 0)
cat("PASS: call sets returned\n")

cs_id <- cs$callSetDbId[1]
cat("Using callSetDbId:", cs_id, "\n")

# ---- 4.4  References and reference sets ----
cat("\n--- brapi_references ---\n")
refs <- tryCatch(
  brapi_references(con),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(refs)) cat("Rows:", nrow(refs), "\n")

cat("\n--- brapi_reference_sets ---\n")
refsets <- tryCatch(
  brapi_reference_sets(con),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(refsets)) cat("Rows:", nrow(refsets), "\n")

# ---- 4.5  Marker map ----
cat("\n--- brapi_get_marker_map ---\n")
mmap <- tryCatch(
  brapi_get_marker_map(con, vs_id),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(mmap)) {
  cat("Rows:", nrow(mmap), "  Cols:", ncol(mmap), "\n")
  cat("Names:", paste0(names(mmap), collapse = ", "), "\n")
  cat("PASS: marker map returned\n")
  print(head(mmap, 5))
}

# ---- 4.6  Raw allele matrix (inspect structure before dosage) ----
cat("\n--- brapi_allele_matrix (raw inspect) ---\n")
am <- tryCatch(
  brapi_allele_matrix(con, variantSetDbId = vs_id),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(am)) {
  cat("Rows:", nrow(am), "  Cols:", ncol(am), "\n")
  cat("Names:", paste0(names(am), collapse = ", "), "\n")
  str(am, max.level = 2)
}

# ---- 4.7  Dosage matrix ----
cat("\n--- brapi_get_dosage_matrix ---\n")
dm <- tryCatch(
  brapi_get_dosage_matrix(con, vs_id),
  error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  }
)
if (!is.null(dm)) {
  if (is.matrix(dm)) {
    cat("Matrix dim:", nrow(dm), "x", ncol(dm), "\n")
    row_preview <- paste0(head(rownames(dm), 3), collapse = ", ")
    col_preview <- paste0(head(colnames(dm), 3), collapse = ", ")
    cat("Row names (samples):", row_preview, "\n")
    cat("Col names (markers):", col_preview, "\n")
    cat("Values (first 3x3):\n")
    print(dm[seq_len(min(3, nrow(dm))), seq_len(min(3, ncol(dm)))])
    cat("PASS: dosage matrix returned\n")
  } else {
    cat("Returned class:", class(dm), "\n")
  }
}

cat("\n==============================\n")
cat("ALL SECTIONS COMPLETE\n")
cat("==============================\n")
