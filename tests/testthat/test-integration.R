## Integration tests against https://test-server.brapi.org
## These tests are skipped on CRAN and when there is no internet connection.
## They validate the full request → parse → tibble pipeline end-to-end.

skip_if_offline_brapi <- function() {
  testthat::skip_if_offline(host = "test-server.brapi.org")
}

SERVER <- "https://test-server.brapi.org"

# ---------------------------------------------------------------------------
# Core module
# ---------------------------------------------------------------------------

test_that("brapi_ping returns TRUE for live server", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  expect_true(brapi_ping(con))
})

test_that("brapi_server_info returns a tibble of supported endpoints", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  info <- brapi_server_info(con)

  expect_s3_class(info, "data.frame")
  expect_gt(nrow(info), 0L)
  expect_true("service" %in% names(info))
  expect_true("methods" %in% names(info))
})

test_that("brapi_programs returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  progs <- brapi_programs(con)

  expect_s3_class(progs, "data.frame")
  expect_gt(nrow(progs), 0L)
  expect_true("programDbId" %in% names(progs))
  expect_true("programName" %in% names(progs))
  expect_type(progs$programDbId, "character")
})

test_that("brapi_trials returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  trials <- brapi_trials(con)

  expect_s3_class(trials, "data.frame")
  expect_gt(nrow(trials), 0L)
  expect_true("trialDbId" %in% names(trials))
})

test_that("brapi_studies returns a tibble with expected columns", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  studies <- brapi_studies(con)

  expect_s3_class(studies, "data.frame")
  expect_gt(nrow(studies), 0L)
  expect_true("studyDbId" %in% names(studies))
  expect_true("studyName" %in% names(studies))
  expect_true("trialDbId" %in% names(studies))
})

test_that("brapi_locations and brapi_seasons return tibbles", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)

  locs <- brapi_locations(con)
  expect_s3_class(locs, "data.frame")
  expect_gt(nrow(locs), 0L)

  seasons <- brapi_seasons(con)
  expect_s3_class(seasons, "data.frame")
  expect_gt(nrow(seasons), 0L)
})

# ---------------------------------------------------------------------------
# Germplasm module
# ---------------------------------------------------------------------------

test_that("brapi_germplasm returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  germ <- brapi_germplasm(con)

  expect_s3_class(germ, "data.frame")
  expect_gt(nrow(germ), 0L)
  expect_true("germplasmDbId" %in% names(germ))
  expect_true("germplasmName" %in% names(germ))
})

test_that("brapi_germplasm_detail returns one row for a valid ID", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  germ_id <- brapi_germplasm(con)$germplasmDbId[[1L]]

  detail <- brapi_germplasm_detail(con, germ_id)

  expect_s3_class(detail, "data.frame")
  expect_identical(nrow(detail), 1L)
  expect_identical(detail$germplasmDbId[[1L]], germ_id)
})

test_that("brapi_germplasm_pedigree returns a single-row tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  germ_id <- brapi_germplasm(con)$germplasmDbId[[1L]]

  ped <- brapi_germplasm_pedigree(con, germ_id)

  expect_s3_class(ped, "data.frame")
  expect_identical(nrow(ped), 1L)
  expect_true("germplasmDbId" %in% names(ped))
})

test_that("brapi_pedigree returns pedigree nodes with tidied relative columns", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  ped <- brapi_pedigree(
    con,
    includeParents = TRUE, includeSiblings = TRUE, includeProgeny = TRUE
  )

  skip_if(nrow(ped) == 0L, "No pedigree records on test server")

  expect_s3_class(ped, "data.frame")
  expect_true("germplasmDbId" %in% names(ped))
  # As of this writing the server returns 3 pedigree nodes, at least one of
  # which (germplasm3) has 2 populated parents - confirms the parents
  # list-column really is tidied into per-node tibbles against live data,
  # not just against the mocked shape.
  expect_true("parents" %in% names(ped))
  non_empty_parents <- vapply(ped$parents, nrow, integer(1)) > 0L
  skip_if(!any(non_empty_parents), "No node with populated parents on test server")
  one_node <- ped$parents[[which(non_empty_parents)[1L]]]
  expect_s3_class(one_node, "data.frame")
  expect_true(all(c("germplasmDbId", "germplasmName", "parentType") %in% names(one_node)))
  expect_gt(nrow(one_node), 0L)
})

test_that("brapi_search_pedigree returns the same node shape as brapi_pedigree", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  ped <- brapi_search_pedigree(con, includeParents = TRUE)

  skip_if(nrow(ped) == 0L, "No pedigree records on test server")

  expect_s3_class(ped, "data.frame")
  expect_true(all(c("germplasmDbId", "parents") %in% names(ped)))
})

# ---------------------------------------------------------------------------
# Phenotyping module
# ---------------------------------------------------------------------------

test_that("brapi_observation_variables returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  vars <- brapi_observation_variables(con)

  expect_s3_class(vars, "data.frame")
  expect_gt(nrow(vars), 0L)
  expect_true("observationVariableDbId" %in% names(vars))
  expect_true("observationVariableName" %in% names(vars))
})

test_that("brapi_observation_units returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  ou <- brapi_observation_units(con)

  expect_s3_class(ou, "data.frame")
  expect_gt(nrow(ou), 0L)
  expect_true("observationUnitDbId" %in% names(ou))
})

test_that("brapi_ontologies returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  onto <- brapi_ontologies(con)

  expect_s3_class(onto, "data.frame")
  expect_gt(nrow(onto), 0L)
  expect_true(all(c("ontologyDbId", "ontologyName") %in% names(onto)))
})

test_that("brapi_ontology returns a single-row tibble for a retrievable ID", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  onto <- brapi_ontologies(con)
  skip_if(nrow(onto) == 0L, "No ontologies on test server")

  # As of this writing, most ontologyDbIds returned by GET /ontologies
  # (UUID-shaped ones) 404 on GET /ontologies/{id} - a real inconsistency
  # in this server's seed data, confirmed directly with curl, not a
  # brapiR2 bug. Only the small number of "O_NNN"-style IDs resolve. Try
  # each ID in turn and skip only if the server has no working one at all,
  # so this test fails loudly if brapiR2 itself breaks, but doesn't fail
  # because of that already-known server data gap.
  working_id <- NULL
  candidates <- utils::head(onto$ontologyDbId, 20L)
  for (id in candidates) {
    result <- tryCatch(brapi_ontology(con, id), error = function(e) NULL)
    if (!is.null(result) && nrow(result) == 1L) {
      working_id <- id
      break
    }
  }
  skip_if(
    is.null(working_id),
    "No individually-retrievable ontologyDbId among the first 20 on test server"
  )

  one <- brapi_ontology(con, working_id)
  expect_s3_class(one, "data.frame")
  expect_identical(nrow(one), 1L)
  expect_identical(one$ontologyDbId[[1L]], working_id)
})

test_that("brapi_study_data returns a wide tibble with trait columns", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)

  # Use first study that has observations
  obs_all <- brapi_observations(con)
  skip_if(nrow(obs_all) == 0L, "No observations on test server")

  study_id <- obs_all$studyDbId[[1L]]
  sd <- brapi_study_data(con, study_id)

  expect_s3_class(sd, "data.frame")
  expect_gt(nrow(sd), 0L)
  expect_true("observationUnitDbId" %in% names(sd))
  # At least one trait column beyond the ID columns
  id_cols <- c(
    "observationUnitDbId", "observationUnitName",
    "germplasmDbId", "germplasmName", "studyDbId", "studyName"
  )
  trait_cols <- setdiff(names(sd), id_cols)
  expect_gt(length(trait_cols), 0L)
})

# ---------------------------------------------------------------------------
# Genotyping module
# ---------------------------------------------------------------------------

test_that("brapi_variant_sets returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  vs <- brapi_variant_sets(con)

  expect_s3_class(vs, "data.frame")
  expect_gt(nrow(vs), 0L)
  expect_true("variantSetDbId" %in% names(vs))
})

test_that("brapi_variants returns variants for a given variantSetDbId", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  vs_id <- brapi_variant_sets(con)$variantSetDbId[[1L]]

  variants <- brapi_variants(con, variantSetDbId = vs_id)

  expect_s3_class(variants, "data.frame")
  expect_gt(nrow(variants), 0L)
  expect_true("variantDbId" %in% names(variants))
})

test_that("brapi_call_sets returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  cs <- brapi_call_sets(con)

  expect_s3_class(cs, "data.frame")
  expect_gt(nrow(cs), 0L)
  expect_true("callSetDbId" %in% names(cs))
})

test_that("brapi_allele_matrix returns a tidy tibble with 3 columns", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  vs_id <- brapi_variant_sets(con)$variantSetDbId[[1L]]

  am <- brapi_allele_matrix(con, variantSetDbId = vs_id)

  expect_s3_class(am, "data.frame")
  expect_gt(nrow(am), 0L)
  expect_named(am, c("variantDbId", "callSetDbId", "genotype"))
  expect_type(am$genotype, "character")
})

test_that("brapi_get_dosage_matrix returns a numeric matrix", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  vs_id <- brapi_variant_sets(con)$variantSetDbId[[1L]]

  dm <- brapi_get_dosage_matrix(con, vs_id)

  expect_true(is.matrix(dm))
  expect_type(dm, "double")
  expect_gt(nrow(dm), 0L)
  expect_gt(ncol(dm), 0L)
  # Dosage values should be 0, 1, 2, or NA
  valid_vals <- all(dm %in% c(0, 1, 2, NA), na.rm = FALSE)
  expect_true(valid_vals)
})

test_that("brapi_maps returns a non-empty tibble with type and unit", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  maps <- brapi_maps(con)

  expect_s3_class(maps, "data.frame")
  expect_gt(nrow(maps), 0L)
  expect_true(all(c("mapDbId", "type", "unit") %in% names(maps)))
})

test_that("brapi_map returns a single-row tibble for a valid ID", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  map_id <- brapi_maps(con)$mapDbId[[1L]]

  m <- brapi_map(con, map_id)

  expect_s3_class(m, "data.frame")
  expect_identical(nrow(m), 1L)
  expect_identical(m$mapDbId[[1L]], map_id)
})

test_that("brapi_map_linkage_groups returns a non-empty tibble", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  map_id <- brapi_maps(con)$mapDbId[[1L]]

  lgs <- brapi_map_linkage_groups(con, map_id)

  expect_s3_class(lgs, "data.frame")
  expect_gt(nrow(lgs), 0L)
  expect_true("linkageGroupName" %in% names(lgs))
})

test_that("brapi_marker_positions filtered by mapDbId returns populated positions", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  map_id <- brapi_maps(con)$mapDbId[[1L]]

  mp <- brapi_marker_positions(con, mapDbId = map_id)

  expect_s3_class(mp, "data.frame")
  expect_gt(nrow(mp), 0L)
  expect_true(all(c("variantDbId", "linkageGroupName", "position") %in% names(mp)))
  # This is the whole point of the Genome Maps entity: positions here are
  # actually populated, unlike brapi_variants()'s start/referenceName on
  # this server.
  expect_false(anyNA(mp$position))
})

test_that("brapi_search_marker_positions returns positions for given variant IDs", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  map_id <- brapi_maps(con)$mapDbId[[1L]]
  v_ids <- brapi_marker_positions(con, mapDbId = map_id)$variantDbId

  sp <- brapi_search_marker_positions(con, variantDbIds = v_ids)

  expect_s3_class(sp, "data.frame")
  expect_gt(nrow(sp), 0L)
  expect_true(all(v_ids %in% sp$variantDbId))
})

test_that("brapi_get_marker_map(mapDbId=) returns a tibble with type and unit", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  map_id <- brapi_maps(con)$mapDbId[[1L]]

  mmap <- brapi_get_marker_map(con, mapDbId = map_id)

  expect_s3_class(mmap, "data.frame")
  expect_gt(nrow(mmap), 0L)
  expect_true(all(c("variantDbId", "type", "unit", "position") %in% names(mmap)))
  expect_false(anyNA(mmap$position))
})

test_that("brapi_get_marker_map(variantSetDbId=) returns positions for the set", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  vs_id <- brapi_variant_sets(con)$variantSetDbId[[1L]]

  # On the public test server only some variants in the set have a
  # marker position record, so a partial-coverage warning is expected;
  # this test only asserts on the returned data, not on the warning.
  mmap <- suppressWarnings(brapi_get_marker_map(con, variantSetDbId = vs_id))

  expect_s3_class(mmap, "data.frame")
  expect_true(all(c("variantDbId", "mapDbId", "type", "unit") %in% names(mmap)))
  if (nrow(mmap) > 0L) {
    expect_false(anyNA(mmap$position))
  }
})

test_that("brapi_get_marker_map errors when neither identifier is given", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)
  expect_error(brapi_get_marker_map(con), "exactly one")
})

# ---------------------------------------------------------------------------
# Full pipeline: programs → trials → studies → study_data
# ---------------------------------------------------------------------------

test_that("full pipeline programs -> trials -> studies -> study_data works", {
  skip_on_cran()
  skip_if_offline_brapi()

  con <- brapi_connection(SERVER)

  # Step 1: list programs
  progs <- brapi_programs(con)
  expect_gt(nrow(progs), 0L)

  # Step 2: list trials (filter by first program)
  prog_id <- progs$programDbId[[1L]]
  trials <- brapi_trials(con, programDbId = prog_id)
  expect_s3_class(trials, "data.frame")

  # Step 3: list studies (get any study)
  studies <- brapi_studies(con)
  expect_gt(nrow(studies), 0L)

  # Step 4: get wide study data for first study that has observations
  obs_all <- brapi_observations(con)
  skip_if(nrow(obs_all) == 0L, "No observations on test server")

  study_id <- obs_all$studyDbId[[1L]]
  sd <- brapi_study_data(con, study_id)

  expect_s3_class(sd, "data.frame")
  expect_gt(nrow(sd), 0L)
  expect_true("observationUnitDbId" %in% names(sd))
})
