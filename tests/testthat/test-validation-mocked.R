## Input validation and error messages: bad arguments fail early with a
## message naming the argument, and HTTP errors name the server.

## Records the URL of every request and answers with an empty collection.
mock_recorder <- function() {
  seen <- new.env(parent = emptyenv())
  seen$urls <- character()
  respond <- function(req) {
    seen$urls <- c(seen$urls, req$url)
    httr2::response(
      status_code = 200L,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw(paste0(
        '{"metadata": {"pagination": {"totalPages": 1}},',
        ' "result": {"data": []}}'
      ))
    )
  }
  list(respond = respond, urls = function() seen$urls)
}

test_that("by-ID functions reject a missing, empty or vector ID", {
  server <- mock_recorder()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")
  con <- brapi_connection("https://example.org")

  for (bad in list(NULL, NA_character_, "", c("a", "b"), 1.5, TRUE)) {
    expect_error(brapi_study(con, bad), "studyDbId")
    expect_error(brapi_program(con, bad), "programDbId")
    expect_error(brapi_trial(con, bad), "trialDbId")
    expect_error(brapi_location(con, bad), "locationDbId")
    expect_error(brapi_list(con, bad), "listDbId")
    expect_error(brapi_germplasm_detail(con, bad), "germplasmDbId")
    expect_error(brapi_ontology(con, bad), "ontologyDbId")
    expect_error(brapi_map(con, bad), "mapDbId")
    expect_error(brapi_map_linkage_groups(con, bad), "mapDbId")
    expect_error(brapi_germplasm_pedigree(con, bad), "germplasmDbId")
    expect_error(brapi_germplasm_progeny(con, bad), "germplasmDbId")
  }
  expect_length(server$urls(), 0L)
})

test_that("by-ID functions URL-encode the ID and accept a whole number", {
  server <- mock_recorder()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")
  con <- brapi_connection("https://example.org")

  brapi_study(con, "a b?c&d")
  brapi_study(con, 6882)
  brapi_map_linkage_groups(con, "map 1")

  urls <- sub("\\?page.*$", "", server$urls())
  expect_identical(urls, c(
    "https://example.org/brapi/v2/studies/a%20b%3Fc%26d",
    "https://example.org/brapi/v2/studies/6882",
    "https://example.org/brapi/v2/maps/map%201/linkagegroups"
  ))
})

test_that("by-ID functions refuse an ID containing a slash", {
  server <- mock_recorder()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")
  con <- brapi_connection("https://example.org")

  expect_error(brapi_study(con, "a/b"), "studyDbId.*can't be sent")
  expect_error(brapi_map_linkage_groups(con, "map/1"), "mapDbId")
  expect_length(server$urls(), 0L)
})

test_that("brapi_get drops NULL query parameters", {
  server <- mock_recorder()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  cached <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = withr::local_tempdir())
  brapi_programs(cached, programName = NULL, abbreviation = "X")

  q <- httr2::url_parse(server$urls()[[1]])$query
  expect_null(q[["programName"]])
  expect_identical(q[["abbreviation"]], "X")
})

test_that("brapi_get explains that a filter takes a single value", {
  server <- mock_recorder()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")
  con <- brapi_connection("https://example.org")

  expect_error(
    brapi_studies(con, studyType = c("Yield", "Disease")),
    "studyType.*single value"
  )
  expect_error(
    brapi_trials(con, programDbId = c("p1", "p2")),
    "programDbId"
  )
  expect_length(server$urls(), 0L)
})

test_that("brapi_connection validates its arguments", {
  url <- "https://example.org"
  expect_error(brapi_connection(url, page_size = "abc"), "page_size")
  expect_error(brapi_connection(url, page_size = 0), "page_size")
  expect_error(brapi_connection(url, page_size = 2.5), "page_size")
  expect_error(brapi_connection(url, timeout = -1), "timeout")
  expect_error(brapi_connection(url, timeout = "60"), "timeout")
  expect_error(brapi_connection(url, token = 123), "token")
  expect_error(brapi_connection(url, token = ""), "token")
  expect_error(brapi_connection(url, version = NULL), "version")
  expect_error(brapi_connection(url, version = ""), "version")

  con <- brapi_connection(url, token = "t", page_size = 50, timeout = 30)
  expect_identical(con$page_size, 50L)
  expect_identical(con$token, "t")
})

test_that("brapi_study_data says when observations have no value column", {
  local_mocked_bindings(
    brapi_observations = function(con, ...) {
      tibble::tibble(
        observationDbId = "o1", observationUnitDbId = "u1",
        studyDbId = "s1", observationVariableName = "height"
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(
    brapi_study_data(con, "s1"),
    "neither a .*value.* nor an .*observationValue"
  )
})

test_that("HTTP errors name the server as well as the endpoint", {
  local_mocked_bindings(
    req_perform = function(req) {
      expect_identical(
        httr2::url_parse(req$url)$query[["page"]], "0"
      )
      httr2::response(
        status_code = 404L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw('{"Message": "Not found"}')
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://breedbase.example.org")
  err <- expect_error(brapi_programs(con), "HTTP 404")
  expect_match(conditionMessage(err), "breedbase.example.org")
  expect_match(conditionMessage(err), "/programs")
})
