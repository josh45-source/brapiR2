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
  wide <- brapi_study_data(con, "study1")

  expect_identical(nrow(wide), 1L)
  expect_identical(wide$Yield, "10")
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
})
