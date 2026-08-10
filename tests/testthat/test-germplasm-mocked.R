## Mocked tests for germplasm-module logic beyond simple thin wrappers -
## specifically brapi_pedigree()/brapi_search_pedigree()'s relative-column
## tidying, which parse_brapi_result() alone does not produce (it leaves
## parents/siblings/progeny as raw nested lists). See tidy_pedigree_nodes()
## and relatives_to_tibble() in R/germplasm.R.

# A raw-shaped PedigreeNode result mimicking what brapi_get()/
# brapi_post_search() would hand back after parse_brapi_result(): one row
# with parents but no progeny, one with progeny but no parents, one with
# neither - covering all three relative-column shapes.
raw_pedigree_nodes <- function() {
  tibble::tibble(
    germplasmDbId = c("A", "B", "C"),
    germplasmName = c("Alpha", "Beta", "Gamma"),
    parents = list(
      list(
        list(germplasmDbId = "P1", germplasmName = "Parent1", parentType = "MALE"),
        list(germplasmDbId = "P2", germplasmName = "Parent2", parentType = "FEMALE")
      ),
      NA,
      NA
    ),
    siblings = list(NA, NA, NA),
    progeny = list(
      NA,
      list(
        list(germplasmDbId = "C1", germplasmName = "Child1", parentType = "FEMALE")
      ),
      NA
    )
  )
}

test_that("brapi_pedigree tidies parents/progeny into per-node tibbles", {
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) raw_pedigree_nodes(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_pedigree(con)

  expect_identical(nrow(result), 3L)
  expect_type(result$parents, "list")
  expect_type(result$siblings, "list")
  expect_type(result$progeny, "list")

  # Node A: has parents, no progeny
  expect_s3_class(result$parents[[1]], "tbl_df")
  expect_identical(nrow(result$parents[[1]]), 2L)
  expect_identical(
    names(result$parents[[1]]),
    c("germplasmDbId", "germplasmName", "parentType")
  )
  expect_identical(result$parents[[1]]$germplasmDbId, c("P1", "P2"))
  expect_identical(result$parents[[1]]$parentType, c("MALE", "FEMALE"))
  expect_identical(nrow(result$progeny[[1]]), 0L)

  # Node B: has progeny, no parents
  expect_identical(nrow(result$parents[[2]]), 0L)
  expect_identical(nrow(result$progeny[[2]]), 1L)
  expect_identical(result$progeny[[2]]$germplasmDbId, "C1")
  expect_identical(result$progeny[[2]]$parentType, "FEMALE")

  # Node C: has neither
  expect_identical(nrow(result$parents[[3]]), 0L)
  expect_identical(nrow(result$progeny[[3]]), 0L)
  expect_identical(nrow(result$siblings[[3]]), 0L)

  # Empty relative tibbles still carry the full column set, not just 0 rows
  # with no columns - important for downstream tidyr::unnest() calls.
  expect_identical(
    names(result$parents[[2]]),
    c("germplasmDbId", "germplasmName", "parentType")
  )
})

test_that("brapi_search_pedigree applies the same relative tidying", {
  local_mocked_bindings(
    brapi_post_search = function(con, endpoint, body = list(), ...) {
      raw_pedigree_nodes()
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_search_pedigree(con, germplasmDbIds = c("A", "B", "C"))

  expect_identical(nrow(result), 3L)
  expect_s3_class(result$parents[[1]], "tbl_df")
  expect_identical(nrow(result$parents[[1]]), 2L)
  expect_identical(nrow(result$progeny[[2]]), 1L)
  expect_identical(nrow(result$parents[[3]]), 0L)
})

test_that("brapi_pedigree passes through unchanged when there are no relative columns", {
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) {
      tibble::tibble(germplasmDbId = c("A", "B"), germplasmName = c("Alpha", "Beta"))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_pedigree(con)

  expect_identical(names(result), c("germplasmDbId", "germplasmName"))
  expect_identical(nrow(result), 2L)
})

test_that("brapi_pedigree returns zero rows unchanged", {
  local_mocked_bindings(
    brapi_get = function(con, endpoint, query = list()) tibble::tibble(),
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  result <- brapi_pedigree(con)

  expect_identical(nrow(result), 0L)
})
