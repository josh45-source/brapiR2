## Mocked tests for brapi_study_data()'s wide-format pivot — no network
## required.

test_that("brapi_study_data pivots observations to wide format", {
  local_mocked_bindings(
    brapi_observations = function(con, studyDbId = NULL, ...) {
      tibble::tibble(
        observationUnitDbId    = c("ou1", "ou1", "ou2", "ou2"),
        studyDbId               = "study1",
        observationVariableName = c("Yield", "Height", "Yield", "Height"),
        value                   = c("10", "150", "12", "160")
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  wide <- brapi_study_data(con, "study1")

  expect_identical(nrow(wide), 2L)
  expect_true(all(c("Yield", "Height") %in% names(wide)))
  expect_identical(
    wide$Yield[wide$observationUnitDbId == "ou1"],
    "10"
  )
})

test_that("brapi_study_data returns an empty tibble with no observations", {
  local_mocked_bindings(
    brapi_observations = function(con, studyDbId = NULL, ...) tibble::tibble(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  wide <- brapi_study_data(con, "study1")

  expect_identical(nrow(wide), 0L)
})

test_that("brapi_study_data falls back to client-side filtering", {
  local_mocked_bindings(
    brapi_observations = function(con, studyDbId = NULL, ...) {
      if (!is.null(studyDbId)) {
        tibble::tibble()
      } else {
        tibble::tibble(
          observationUnitDbId    = "ou1",
          studyDbId               = "study1",
          observationVariableName = "Yield",
          value                   = "10"
        )
      }
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  wide <- brapi_study_data(con, "study1", fallback = TRUE)

  expect_identical(nrow(wide), 1L)
  expect_identical(wide$Yield, "10")
})

test_that("brapi_study_data fallback filters by requested study, not itself", {
  # Regression test: the fallback previously did
  # `dplyr::filter(all_obs, .data$studyDbId == studyDbId)`, where the bare
  # `studyDbId` inside filter() resolves to the DATA COLUMN (same name),
  # not the function argument - making the comparison a tautology that
  # matched every row regardless of which study was requested.
  local_mocked_bindings(
    brapi_observations = function(con, studyDbId = NULL, ...) {
      if (!is.null(studyDbId)) {
        tibble::tibble()
      } else {
        tibble::tibble(
          observationUnitDbId    = "ou1",
          studyDbId               = "study1",
          observationVariableName = "Yield",
          value                   = "10"
        )
      }
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")

  # A study genuinely absent from the unfiltered data must come back empty,
  # not silently return study1's rows.
  wide <- suppressMessages(brapi_study_data(con, "study2", fallback = TRUE))
  expect_identical(nrow(wide), 0L)
})

test_that("brapi_study_data uses observationValue/DbId fallback column names", {
  local_mocked_bindings(
    brapi_observations = function(con, studyDbId = NULL, ...) {
      tibble::tibble(
        observationUnitDbId     = c("ou1", "ou1"),
        studyDbId                = "study1",
        observationVariableDbId = c("var1", "var2"),
        observationValue         = c("10", "150")
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  wide <- brapi_study_data(con, "study1")

  expect_identical(nrow(wide), 1L)
  expect_true(all(c("var1", "var2") %in% names(wide)))
  expect_identical(wide$var1, "10")
  expect_identical(wide$var2, "150")
})

test_that("brapi_study_data fills unmeasured traits with NA, not a short column", {
  local_mocked_bindings(
    brapi_observations = function(con, ...) {
      tibble::tibble(
        observationUnitDbId = c("u1", "u2", "u1"),
        observationUnitName = c("p1", "p2", "p1"),
        germplasmDbId = c("g1", "g1", "g1"),
        germplasmName = c("G", "G", "G"),
        studyDbId = c("s1", "s1", "s1"),
        observationVariableName = c("height", "height", "yield"),
        value = c("10", "20", "5")
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  out <- brapi_study_data(con, "s1")

  expect_identical(nrow(out), 2L)
  expect_false(any(vapply(out, is.list, logical(1))))
  # u2 has no yield observation, so that cell must be NA rather than dropped.
  expect_true(is.na(out$yield[out$observationUnitDbId == "u2"]))
})

test_that("brapi_study_data trims whitespace around values", {
  local_mocked_bindings(
    brapi_observations = function(con, ...) {
      tibble::tibble(
        observationUnitDbId = c("u1", "u2"),
        observationUnitName = c("p1", "p2"),
        germplasmDbId = c("g1", "g1"),
        germplasmName = c("G", "G"),
        studyDbId = c("s1", "s1"),
        observationVariableName = c("height", "height"),
        value = c("150", " 80 ")
      )
    },
    .package = "brapiR2"
  )

  out <- brapi_study_data(brapi_connection("https://example.org"), "s1")
  expect_identical(sort(out$height), c("150", "80"))
})

test_that("brapi_study_data filters when the server ignores studyDbId", {
  local_mocked_bindings(
    brapi_observations = function(con, ...) {
      tibble::tibble(
        observationUnitDbId = c("u1", "u2"),
        observationUnitName = c("p1", "p2"),
        germplasmDbId = c("g1", "g2"),
        germplasmName = c("A", "B"),
        studyDbId = c("s1", "s2"),
        observationVariableName = c("height", "height"),
        value = c("10", "20")
      )
    },
    .package = "brapiR2"
  )

  out <- brapi_study_data(brapi_connection("https://example.org"), "s1")
  expect_identical(nrow(out), 1L)
  expect_identical(out$studyDbId, "s1")
})

test_that("brapi_study_data keeps repeated measurements with equal values", {
  local_mocked_bindings(
    brapi_observations = function(con, ...) {
      tibble::tibble(
        observationDbId = c("o1", "o2"),
        observationUnitDbId = "u1",
        studyDbId = "s1",
        observationVariableName = "height",
        value = c("10", "10"),
        observationTimeStamp = c("2024-06-01", "2024-07-01")
      )
    },
    .package = "brapiR2"
  )

  out <- brapi_study_data(brapi_connection("https://example.org"), "s1")
  expect_identical(out$height, list(c("10", "10")))
})

test_that("brapi_study_data drops a record the server sent twice", {
  local_mocked_bindings(
    brapi_observations = function(con, ...) {
      tibble::tibble(
        observationDbId = c("o1", "o1", "o2"),
        observationUnitDbId = c("u1", "u1", "u2"),
        studyDbId = "s1",
        observationVariableName = "height",
        value = c("10", "10", "12")
      )
    },
    .package = "brapiR2"
  )

  expect_message(
    out <- brapi_study_data(brapi_connection("https://example.org"), "s1"),
    "Dropped 1 duplicate"
  )
  expect_identical(out$height[out$observationUnitDbId == "u1"], "10")
})

## /observations on a server that ignores nothing: the filtered request
## returns the study's records, here none. Records each request's query.
mock_observations_server <- function() {
  seen <- new.env(parent = emptyenv())
  seen$queries <- list()
  respond <- function(req) {
    expect_match(req$url, "/brapi/v2/observations\\?")
    q <- httr2::url_parse(req$url)$query
    seen$queries[[length(seen$queries) + 1L]] <- q
    data <- if (is.null(q[["studyDbId"]])) {
      list(list(observationDbId = "o1", observationUnitDbId = "u1",
                studyDbId = "s1", observationVariableName = "height",
                value = "10"))
    } else {
      list()
    }
    httr2::response(
      status_code = 200L,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw(jsonlite::toJSON(list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(data = data)
      ), auto_unbox = TRUE))
    )
  }
  list(respond = respond, queries = function() seen$queries)
}

test_that("brapi_study_data doesn't fetch the whole server by default", {
  server <- mock_observations_server()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org")
  expect_message(
    out <- brapi_study_data(con, "s1"),
    "fallback = TRUE"
  )

  expect_identical(nrow(out), 0L)
  queries <- server$queries()
  expect_length(queries, 1L)
  expect_identical(queries[[1]][["studyDbId"]], "s1")
})

test_that("brapi_study_data's empty-study message names the test server", {
  server <- mock_observations_server()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org")
  expect_message(brapi_study_data(con, "s1"), "test-server.brapi.org")
})

test_that("brapi_study_data(fallback = TRUE) filters an unfiltered fetch", {
  server <- mock_observations_server()
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org")
  out <- brapi_study_data(con, "s1", fallback = TRUE)

  expect_identical(out$height, "10")
  queries <- server$queries()
  expect_length(queries, 2L)
  expect_identical(queries[[1]][["studyDbId"]], "s1")
  expect_null(queries[[2]][["studyDbId"]])
})

test_that("brapi_study_data rejects a non-logical fallback", {
  con <- brapi_connection("https://example.org")
  expect_error(brapi_study_data(con, "s1", fallback = "yes"), "fallback")
})
