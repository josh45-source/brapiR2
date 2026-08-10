## Most exported list/get functions are one-line wrappers around
## brapi_get() or brapi_post_search(). Mocking those two internal
## functions once exercises every wrapper's own body without any network.
##
## The mocks below capture the arguments they were called with (endpoint,
## query, body) so each assertion can check that a wrapper hit the right
## BrAPI path and threaded its ID/filter arguments through under the
## correct key - not just that it returned whatever the mock handed back.

test_that("core wrappers hit the right endpoint and pass filters through", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      captured$endpoint <- endpoint
      captured$query <- query
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_programs(con), canned)
  expect_identical(captured$endpoint, "/programs")
  brapi_programs(con, commonCropName = "rice")
  expect_identical(captured$query$commonCropName, "rice")

  expect_identical(brapi_program(con, "p1"), canned)
  expect_identical(captured$endpoint, "/programs/p1")

  expect_identical(brapi_trials(con), canned)
  expect_identical(captured$endpoint, "/trials")
  brapi_trials(con, programDbId = "p1")
  expect_identical(captured$query$programDbId, "p1")

  expect_identical(brapi_trial(con, "t1"), canned)
  expect_identical(captured$endpoint, "/trials/t1")

  expect_identical(brapi_studies(con), canned)
  expect_identical(captured$endpoint, "/studies")
  brapi_studies(con, trialDbId = "t1")
  expect_identical(captured$query$trialDbId, "t1")

  expect_identical(brapi_study(con, "s1"), canned)
  expect_identical(captured$endpoint, "/studies/s1")

  expect_identical(brapi_locations(con), canned)
  expect_identical(captured$endpoint, "/locations")
  brapi_locations(con, locationType = "Field")
  expect_identical(captured$query$locationType, "Field")

  expect_identical(brapi_seasons(con), canned)
  expect_identical(captured$endpoint, "/seasons")
  brapi_seasons(con, year = 2020)
  expect_identical(captured$query$year, 2020)

  expect_identical(brapi_lists(con), canned)
  expect_identical(captured$endpoint, "/lists")

  expect_identical(brapi_people(con), canned)
  expect_identical(captured$endpoint, "/people")
})

test_that("germplasm wrappers hit the right endpoint and pass filters", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      captured$endpoint <- endpoint
      captured$query <- query
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_germplasm(con), canned)
  expect_identical(captured$endpoint, "/germplasm")
  brapi_germplasm(con, germplasmName = "Line1")
  expect_identical(captured$query$germplasmName, "Line1")

  expect_identical(brapi_germplasm_detail(con, "g1"), canned)
  expect_identical(captured$endpoint, "/germplasm/g1")

  expect_identical(brapi_germplasm_pedigree(con, "g1"), canned)
  expect_identical(captured$endpoint, "/germplasm/g1/pedigree")

  expect_identical(brapi_germplasm_progeny(con, "g1"), canned)
  expect_identical(captured$endpoint, "/germplasm/g1/progeny")

  expect_identical(brapi_germplasm_attributes(con), canned)
  expect_identical(captured$endpoint, "/attributes")

  expect_identical(brapi_crosses(con), canned)
  expect_identical(captured$endpoint, "/crosses")

  expect_identical(brapi_crossing_projects(con), canned)
  expect_identical(captured$endpoint, "/crossingprojects")

  expect_identical(brapi_seed_lots(con), canned)
  expect_identical(captured$endpoint, "/seedlots")
})

test_that("brapi_pedigree hits /pedigree and passes filters through", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      captured$endpoint <- endpoint
      captured$query <- query
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_pedigree(con), canned)
  expect_identical(captured$endpoint, "/pedigree")
  expect_null(captured$query$germplasmDbId)

  brapi_pedigree(con, germplasmDbId = "g1")
  expect_identical(captured$query$germplasmDbId, "g1")

  brapi_pedigree(
    con,
    includeParents = TRUE, includeSiblings = TRUE, includeProgeny = TRUE,
    includeFullTree = FALSE, pedigreeDepth = 2L, progenyDepth = 3L
  )
  expect_true(captured$query$includeParents)
  expect_true(captured$query$includeSiblings)
  expect_true(captured$query$includeProgeny)
  expect_false(captured$query$includeFullTree)
  expect_identical(captured$query$pedigreeDepth, 2L)
  expect_identical(captured$query$progenyDepth, 3L)

  brapi_pedigree(con, collection = "RDP1")
  expect_identical(captured$query$collection, "RDP1")
})

test_that("brapi_search_pedigree hits /search/pedigree and passes body fields", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_post_search = function(con, endpoint, body = list(), ...) {
      captured$endpoint <- endpoint
      captured$body <- body
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(
    brapi_search_pedigree(con, germplasmDbIds = c("g1", "g2")),
    canned
  )
  expect_identical(captured$endpoint, "/search/pedigree")
  expect_identical(captured$body$germplasmDbIds, c("g1", "g2"))

  brapi_search_pedigree(
    con,
    includeParents = TRUE, includeProgeny = TRUE, pedigreeDepth = 4L
  )
  expect_true(captured$body$includeParents)
  expect_true(captured$body$includeProgeny)
  expect_identical(captured$body$pedigreeDepth, 4L)

  brapi_search_pedigree(con, familyCodes = "F0000203")
  expect_identical(captured$body$familyCodes, "F0000203")
})

test_that("phenotyping wrappers hit the right endpoint and pass filters", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      captured$endpoint <- endpoint
      captured$query <- query
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_observation_units(con), canned)
  expect_identical(captured$endpoint, "/observationunits")
  brapi_observation_units(con, studyDbId = "s1")
  expect_identical(captured$query$studyDbId, "s1")

  expect_identical(brapi_observations(con), canned)
  expect_identical(captured$endpoint, "/observations")
  brapi_observations(con, studyDbId = "s1")
  expect_identical(captured$query$studyDbId, "s1")

  expect_identical(brapi_observation_variables(con), canned)
  expect_identical(captured$endpoint, "/variables")

  expect_identical(brapi_traits(con), canned)
  expect_identical(captured$endpoint, "/traits")

  expect_identical(brapi_scales(con), canned)
  expect_identical(captured$endpoint, "/scales")

  expect_identical(brapi_methods(con), canned)
  expect_identical(captured$endpoint, "/methods")

  expect_identical(brapi_images(con), canned)
  expect_identical(captured$endpoint, "/images")

  expect_identical(brapi_events(con), canned)
  expect_identical(captured$endpoint, "/events")
  brapi_events(con, studyDbId = "s1")
  expect_identical(captured$query$studyDbId, "s1")

  expect_identical(brapi_ontologies(con), canned)
  expect_identical(captured$endpoint, "/ontologies")
  brapi_ontologies(con, ontologyName = "Ontology.org")
  expect_identical(captured$query$ontologyName, "Ontology.org")

  expect_identical(brapi_ontology(con, "o1"), canned)
  expect_identical(captured$endpoint, "/ontologies/o1")
})

test_that("genotyping wrappers hit the right endpoint and pass filters", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      captured$endpoint <- endpoint
      captured$query <- query
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_samples(con), canned)
  expect_identical(captured$endpoint, "/samples")

  expect_identical(brapi_variants(con), canned)
  expect_identical(captured$endpoint, "/variants")
  brapi_variants(con, variantSetDbId = "vs1")
  expect_identical(captured$query$variantSetDbId, "vs1")

  expect_identical(brapi_variant_sets(con), canned)
  expect_identical(captured$endpoint, "/variantsets")
  brapi_variant_sets(con, studyDbId = "s1")
  expect_identical(captured$query$studyDbId, "s1")

  expect_identical(brapi_calls(con), canned)
  expect_identical(captured$endpoint, "/calls")
  brapi_calls(con, variantSetDbId = "vs1")
  expect_identical(captured$query$variantSetDbId, "vs1")

  expect_identical(brapi_call_sets(con), canned)
  expect_identical(captured$endpoint, "/callsets")

  expect_identical(brapi_references(con), canned)
  expect_identical(captured$endpoint, "/references")

  expect_identical(brapi_reference_sets(con), canned)
  expect_identical(captured$endpoint, "/referencesets")
})

test_that("genome maps wrappers hit the right endpoint and pass filters", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      captured$endpoint <- endpoint
      captured$query <- query
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_maps(con), canned)
  expect_identical(captured$endpoint, "/maps")

  expect_identical(brapi_map(con, "map1"), canned)
  expect_identical(captured$endpoint, "/maps/map1")

  expect_identical(brapi_map_linkage_groups(con, "map1"), canned)
  expect_identical(captured$endpoint, "/maps/map1/linkagegroups")

  expect_identical(brapi_marker_positions(con), canned)
  expect_identical(captured$endpoint, "/markerpositions")
  expect_null(captured$query$mapDbId)

  brapi_marker_positions(con, mapDbId = "map1")
  expect_identical(captured$query$mapDbId, "map1")

  brapi_marker_positions(con, variantDbId = "v1")
  expect_identical(captured$query$variantDbId, "v1")

  brapi_marker_positions(con, linkageGroupName = "Chromosome 1")
  expect_identical(captured$query$linkageGroupName, "Chromosome 1")

  brapi_marker_positions(con, minPosition = 100, maxPosition = 200)
  expect_identical(captured$query$minPosition, 100)
  expect_identical(captured$query$maxPosition, 200)
})


test_that("search wrappers hit the right endpoint and pass body fields", {
  captured <- new.env()
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_post_search = function(con, endpoint, body = list(), ...) {
      captured$endpoint <- endpoint
      captured$body <- body
      canned
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_search_germplasm(con, germplasmNames = "a"), canned)
  expect_identical(captured$endpoint, "/search/germplasm")
  expect_identical(captured$body$germplasmNames, "a")

  expect_identical(brapi_search_variants(con, variantSetDbIds = "vs1"), canned)
  expect_identical(captured$endpoint, "/search/variants")
  expect_identical(captured$body$variantSetDbIds, "vs1")

  expect_identical(
    brapi_search_calls(con, variantSetDbIds = "vs1", callSetDbIds = "cs1"),
    canned
  )
  expect_identical(captured$endpoint, "/search/calls")
  expect_identical(captured$body$variantSetDbIds, "vs1")
  expect_identical(captured$body$callSetDbIds, "cs1")

  expect_identical(brapi_search_observations(con, studyDbIds = "s1"), canned)
  expect_identical(captured$endpoint, "/search/observations")
  expect_identical(captured$body$studyDbIds, "s1")

  expect_identical(
    brapi_search_variables(con, traitClasses = "agronomic"),
    canned
  )
  expect_identical(captured$endpoint, "/search/variables")
  expect_identical(captured$body$traitClasses, "agronomic")

  expect_identical(
    brapi_search_marker_positions(con, variantDbIds = c("v1", "v2")),
    canned
  )
  expect_identical(captured$endpoint, "/search/markerpositions")
  expect_identical(captured$body$variantDbIds, c("v1", "v2"))

  brapi_search_marker_positions(
    con,
    mapDbIds = "map1", linkageGroupNames = "Chromosome 1",
    minPosition = 100, maxPosition = 200
  )
  expect_identical(captured$body$mapDbIds, "map1")
  expect_identical(captured$body$linkageGroupNames, "Chromosome 1")
  expect_identical(captured$body$minPosition, 100)
  expect_identical(captured$body$maxPosition, 200)
})

test_that("brapi_server_info parses the calls array from /serverinfo", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      # Mirrors what jsonlite::fromJSON(simplifyVector = TRUE) produces for
      # an array of call objects: a data.frame, not a list of lists.
      list(result = list(calls = data.frame(
        service = "programs",
        stringsAsFactors = FALSE
      )))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  info <- brapi_server_info(con)

  expect_s3_class(info, "tbl_df")
  expect_identical(info$service, "programs")
})

test_that("brapi_server_info returns an empty tibble with no calls", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) list(result = list(calls = list())),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  info <- brapi_server_info(con)

  expect_identical(nrow(info), 0L)
})

test_that("brapi_endpoints delegates to brapi_server_info", {
  canned <- tibble::tibble(service = "programs")
  local_mocked_bindings(
    brapi_server_info = function(con) canned,
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_identical(brapi_endpoints(con), canned)
})

test_that("brapi_ping returns TRUE when the server responds 200", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_status = function(resp) 200L,
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_true(isTRUE(brapi_ping(con)))
})

test_that("brapi_ping returns FALSE on a non-200 status", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_status = function(resp) 503L,
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_false(isTRUE(brapi_ping(con)))
})

test_that("brapi_ping returns FALSE when the request errors", {
  local_mocked_bindings(
    req_perform = function(req) stop("connection refused"),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_false(isTRUE(brapi_ping(con)))
})
