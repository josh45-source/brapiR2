## Mocked tests for the genotyping convenience functions — no network
## required.

test_that("brapi_allele_matrix assembles a tidy tibble from a paged response", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(result = list(
        pagination = list(list(dimension = "CALLSETS", totalPages = 1L)),
        callSetDbIds = list("s1", "s2"),
        variantDbIds = list("v1", "v2"),
        dataMatrices = list(list(
          dataMatrixName = "Genotype",
          dataMatrixAbbreviation = "GT",
          dataMatrix = list(
            list("0/0", "0/1"),
            list("1/1", "./.")
          )
        ))
      ))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_allele_matrix(con, variantSetDbId = "vs1")

  expect_identical(nrow(result), 4L)
  expect_setequal(result$genotype, c("0/0", "0/1", "1/1", "./."))
  expect_setequal(names(result), c("variantDbId", "callSetDbId", "genotype"))
})

test_that("brapi_allele_matrix returns an empty tibble with no variants", {
  local_mocked_bindings(
    req_perform = function(req) structure(list(), class = "httr2_response"),
    resp_body_json = function(resp, ...) {
      list(result = list(
        pagination = list(list(dimension = "CALLSETS", totalPages = 1L)),
        callSetDbIds = list(),
        variantDbIds = list(),
        dataMatrices = list()
      ))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_allele_matrix(con, variantSetDbId = "vs1")

  expect_identical(nrow(result), 0L)
})

test_that("brapi_get_dosage_matrix converts genotypes into allele dosages", {
  local_mocked_bindings(
    brapi_allele_matrix = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble(
        variantDbId = c("v1", "v1", "v2", "v2"),
        callSetDbId = c("s1", "s2", "s1", "s2"),
        genotype    = c("0/0", "0/1", "1/1", ".")
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  dm <- brapi_get_dosage_matrix(con, "vs1")

  expect_true(is.matrix(dm))
  expect_identical(dim(dm), c(2L, 2L))
  expect_identical(rownames(dm), c("s1", "s2"))
  expect_identical(unname(dm["s1", "v1"]), 0)
  expect_identical(unname(dm["s2", "v1"]), 1)
  expect_identical(unname(dm["s1", "v2"]), 2)
  expect_true(is.na(dm["s2", "v2"]))
})

test_that("brapi_get_dosage_matrix handles phased genotype separators", {
  local_mocked_bindings(
    brapi_allele_matrix = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble(
        variantDbId = c("v1", "v1"),
        callSetDbId = c("s1", "s2"),
        genotype    = c("0|1", "1|1")
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  dm <- brapi_get_dosage_matrix(con, "vs1")

  expect_identical(unname(dm["s1", "v1"]), 1)
  expect_identical(unname(dm["s2", "v1"]), 2)
})

test_that("brapi_get_dosage_matrix errors when no allele matrix is returned", {
  local_mocked_bindings(
    brapi_allele_matrix = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble()
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(brapi_get_dosage_matrix(con, "vs1"), "No allele matrix data")
})

test_that("brapi_get_marker_map returns tidy marker positions", {
  local_mocked_bindings(
    brapi_variants = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble(
        variantDbId   = c("v1", "v2"),
        variantName   = c("m1", "m2"),
        referenceName = c("1", "1"),
        start         = c(100L, 200L)
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  markers <- brapi_get_marker_map(con, "vs1")

  expect_identical(nrow(markers), 2L)
  expect_identical(
    names(markers),
    c("variantDbId", "variantName", "referenceName", "start")
  )
})

test_that("brapi_get_marker_map handles a variantNames list-column", {
  local_mocked_bindings(
    brapi_variants = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble(
        variantDbId   = "v1",
        variantNames  = list(list("m1")),
        referenceName = "1",
        start         = 100L
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  markers <- brapi_get_marker_map(con, "vs1")

  expect_identical(markers$variantName, "m1")
  expect_false("variantNames" %in% names(markers))
})

test_that("brapi_get_marker_map returns an empty tibble with no variants", {
  local_mocked_bindings(
    brapi_variants = function(con, variantSetDbId = NULL, ...) tibble::tibble(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  markers <- brapi_get_marker_map(con, "vs1")

  expect_identical(nrow(markers), 0L)
  expect_identical(
    names(markers),
    c("variantDbId", "variantName", "referenceName", "start")
  )
})
