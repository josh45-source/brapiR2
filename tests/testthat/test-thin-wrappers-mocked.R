## Most exported list/get functions are one-line wrappers around
## brapi_get() or brapi_post_search(). Mocking those two internal
## functions once exercises every wrapper's own body without any network.

test_that("GET-based list/detail wrappers call brapi_get() and return it", {
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) canned,
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_programs(con), canned)
  expect_identical(brapi_program(con, "p1"), canned)
  expect_identical(brapi_trials(con), canned)
  expect_identical(brapi_trials(con, programDbId = "p1"), canned)
  expect_identical(brapi_trial(con, "t1"), canned)
  expect_identical(brapi_studies(con), canned)
  expect_identical(brapi_studies(con, trialDbId = "t1"), canned)
  expect_identical(brapi_study(con, "s1"), canned)
  expect_identical(brapi_locations(con), canned)
  expect_identical(brapi_seasons(con), canned)
  expect_identical(brapi_lists(con), canned)
  expect_identical(brapi_people(con), canned)

  expect_identical(brapi_samples(con), canned)
  expect_identical(brapi_variants(con), canned)
  expect_identical(brapi_variants(con, variantSetDbId = "vs1"), canned)
  expect_identical(brapi_variant_sets(con), canned)
  expect_identical(brapi_variant_sets(con, studyDbId = "s1"), canned)
  expect_identical(brapi_calls(con), canned)
  expect_identical(brapi_calls(con, variantSetDbId = "vs1"), canned)
  expect_identical(brapi_call_sets(con), canned)
  expect_identical(brapi_references(con), canned)
  expect_identical(brapi_reference_sets(con), canned)

  expect_identical(brapi_germplasm(con), canned)
  expect_identical(brapi_germplasm_detail(con, "g1"), canned)
  expect_identical(brapi_germplasm_pedigree(con, "g1"), canned)
  expect_identical(brapi_germplasm_progeny(con, "g1"), canned)
  expect_identical(brapi_germplasm_attributes(con), canned)
  expect_identical(brapi_crosses(con), canned)
  expect_identical(brapi_crossing_projects(con), canned)
  expect_identical(brapi_seed_lots(con), canned)

  expect_identical(brapi_observation_units(con), canned)
  expect_identical(brapi_observation_units(con, studyDbId = "s1"), canned)
  expect_identical(brapi_observations(con), canned)
  expect_identical(brapi_observations(con, studyDbId = "s1"), canned)
  expect_identical(brapi_observation_variables(con), canned)
  expect_identical(brapi_traits(con), canned)
  expect_identical(brapi_scales(con), canned)
  expect_identical(brapi_methods(con), canned)
  expect_identical(brapi_images(con), canned)
  expect_identical(brapi_events(con), canned)
  expect_identical(brapi_events(con, studyDbId = "s1"), canned)
})

test_that("search wrappers call brapi_post_search() and return it", {
  canned <- tibble::tibble(id = "x")
  local_mocked_bindings(
    brapi_post_search = function(con, endpoint, body = list(), ...) canned,
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  expect_identical(brapi_search_germplasm(con, germplasmNames = "a"), canned)
  expect_identical(brapi_search_variants(con, variantSetDbIds = "vs1"), canned)
  expect_identical(
    brapi_search_calls(con, variantSetDbIds = "vs1", callSetDbIds = "cs1"),
    canned
  )
  expect_identical(brapi_search_observations(con, studyDbIds = "s1"), canned)
  expect_identical(
    brapi_search_variables(con, traitClasses = "agronomic"),
    canned
  )
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
