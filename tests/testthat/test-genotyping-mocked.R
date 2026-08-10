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

## brapi_get_marker_map() sources positions from the Genome Maps entity
## (brapi_marker_positions()/brapi_search_marker_positions()), not from
## brapi_variants() - it just uses brapi_variants() to look up which
## variant IDs belong to a set, in the variantSetDbId path.

MARKER_MAP_COLS <- c(
  "variantDbId", "variantName", "mapDbId", "mapName", "type", "unit",
  "linkageGroupName", "position"
)

test_that("brapi_get_marker_map(mapDbId=) joins map metadata onto positions", {
  local_mocked_bindings(
    brapi_marker_positions = function(con, mapDbId = NULL, ...) {
      tibble::tibble(
        variantDbId      = c("v1", "v2"),
        variantName      = c("m1", "m2"),
        mapDbId           = c("map1", "map1"),
        mapName           = c("Map One", "Map One"),
        linkageGroupName  = c("Chromosome 1", "Chromosome 1"),
        position          = c(100L, 200L)
      )
    },
    brapi_maps = function(con, ...) {
      tibble::tibble(
        mapDbId = "map1", mapName = "Map One", type = "Genetic", unit = "cM"
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  markers <- brapi_get_marker_map(con, mapDbId = "map1")

  expect_identical(nrow(markers), 2L)
  expect_identical(names(markers), MARKER_MAP_COLS)
  expect_identical(markers$type, c("Genetic", "Genetic"))
  expect_identical(markers$unit, c("cM", "cM"))
  expect_identical(markers$position, c(100L, 200L))
})

test_that("brapi_get_marker_map(variantSetDbId=) bridges through search", {
  captured <- new.env()
  local_mocked_bindings(
    brapi_variants = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble(variantDbId = c("v1", "v2"))
    },
    brapi_search_marker_positions = function(con, variantDbIds = NULL, ...) {
      captured$variantDbIds <- variantDbIds
      tibble::tibble(
        variantDbId      = c("v1", "v2"),
        variantName      = c("m1", "m2"),
        mapDbId           = c("map1", "map1"),
        linkageGroupName  = c("Chromosome 1", "Chromosome 1"),
        position          = c(100L, 200L)
      )
    },
    brapi_maps = function(con, ...) {
      tibble::tibble(
        mapDbId = "map1", mapName = "Map One", type = "Genetic", unit = "cM"
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_no_warning(
    markers <- brapi_get_marker_map(con, variantSetDbId = "vs1")
  )

  expect_identical(captured$variantDbIds, c("v1", "v2"))
  expect_identical(nrow(markers), 2L)
  expect_identical(names(markers), MARKER_MAP_COLS)
})

test_that("brapi_get_marker_map warns when some variants lack positions", {
  local_mocked_bindings(
    brapi_variants = function(con, variantSetDbId = NULL, ...) {
      tibble::tibble(variantDbId = c("v1", "v2", "v3"))
    },
    brapi_search_marker_positions = function(con, variantDbIds = NULL, ...) {
      tibble::tibble(
        variantDbId      = "v1",
        variantName      = "m1",
        mapDbId           = "map1",
        linkageGroupName  = "Chromosome 1",
        position          = 100L
      )
    },
    brapi_maps = function(con, ...) {
      tibble::tibble(
        mapDbId = "map1", mapName = "Map One", type = "Genetic", unit = "cM"
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_warning(
    markers <- brapi_get_marker_map(con, variantSetDbId = "vs1"),
    "2 of 3 variants"
  )
  expect_identical(nrow(markers), 1L)
})

test_that("brapi_get_marker_map returns empty tibble with no variants in set", {
  local_mocked_bindings(
    brapi_variants = function(con, variantSetDbId = NULL, ...) tibble::tibble(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_warning(
    markers <- brapi_get_marker_map(con, variantSetDbId = "vs1"),
    "No variants found"
  )
  expect_identical(nrow(markers), 0L)
  expect_identical(names(markers), MARKER_MAP_COLS)
})

test_that("brapi_get_marker_map returns empty tibble when map has no positions", {
  local_mocked_bindings(
    brapi_marker_positions = function(con, mapDbId = NULL, ...) tibble::tibble(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_warning(
    markers <- brapi_get_marker_map(con, mapDbId = "map1"),
    "No marker positions found"
  )
  expect_identical(nrow(markers), 0L)
  expect_identical(names(markers), MARKER_MAP_COLS)
})

test_that("brapi_get_marker_map errors when neither identifier is given", {
  con <- brapi_connection("https://example.org")
  expect_error(brapi_get_marker_map(con), "exactly one")
})

test_that("brapi_get_marker_map errors when both identifiers are given", {
  con <- brapi_connection("https://example.org")
  expect_error(
    brapi_get_marker_map(con, variantSetDbId = "vs1", mapDbId = "map1"),
    "exactly one"
  )
})
