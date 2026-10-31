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

## A spec-compliant /allelematrix server: 4 variants x 4 call sets, served 2 x 2
## per page. It only understands the v2.1 parameter names, so a client paging
## with anything else gets page 0 back every time. `genotype` builds each cell
## from its variant and call set indices.
mock_allele_matrix_server <- function(genotype) {
  variants <- paste0("v", 1:4)
  callsets <- paste0("s", 1:4)
  seen <- new.env(parent = emptyenv())
  seen$requests <- list()
  respond <- function(req) {
    q <- httr2::url_parse(req$url)$query
    seen$requests[[length(seen$requests) + 1L]] <- q
    vp <- as.integer(q[["dimensionVariantPage"]] %||% 0L)
    cp <- as.integer(q[["dimensionCallSetPage"]] %||% 0L)
    vi <- 2L * vp + 1:2
    ci <- 2L * cp + 1:2
    body <- list(result = list(
      pagination = list(
        list(dimension = "VARIANTS", page = vp, pageSize = 2L,
             totalCount = 4L, totalPages = 2L),
        list(dimension = "CALLSETS", page = cp, pageSize = 2L,
             totalCount = 4L, totalPages = 2L)
      ),
      variantDbIds = as.list(variants[vi]),
      callSetDbIds = as.list(callsets[ci]),
      dataMatrices = list(list(
        dataMatrixName = "Genotype",
        dataMatrixAbbreviation = "GT",
        dataMatrix = lapply(vi, function(v) {
          lapply(ci, function(cs) genotype(v, cs))
        })
      ))
    ))
    httr2::response(
      status_code = 200L,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw(jsonlite::toJSON(body, auto_unbox = TRUE))
    )
  }
  list(respond = respond, requests = function() seen$requests)
}

test_that("brapi_allele_matrix pages both dimensions with the v2.1 names", {
  server <- mock_allele_matrix_server(function(v, cs) paste0("v", v, ":s", cs))
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org", page_size = 2L)
  result <- brapi_allele_matrix(con, variantSetDbId = "vs1")

  requests <- server$requests()
  expect_length(requests, 4L)
  for (q in requests) {
    expect_identical(q$variantSetDbId, "vs1")
    expect_identical(q[["dimensionVariantPageSize"]], "2")
    expect_identical(q[["dimensionCallSetPageSize"]], "2")
    expect_null(q[["callSetPage"]])
    expect_null(q[["pageSize"]])
  }
  pages <- vapply(requests, function(q) {
    paste(q[["dimensionVariantPage"]], q[["dimensionCallSetPage"]])
  }, character(1))
  expect_setequal(pages, c("0 0", "0 1", "1 0", "1 1"))

  expect_identical(nrow(result), 16L)
  expect_identical(nrow(unique(result[, c("variantDbId", "callSetDbId")])), 16L)
  expect_identical(
    result$genotype,
    paste0(result$variantDbId, ":", result$callSetDbId)
  )
})

test_that("brapi_allele_matrix fetches only a page the caller pins", {
  server <- mock_allele_matrix_server(function(v, cs) paste0("v", v, ":s", cs))
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org", page_size = 2L)
  result <- brapi_allele_matrix(
    con, variantSetDbId = "vs1", dimensionCallSetPage = 1L
  )

  requests <- server$requests()
  expect_length(requests, 2L)
  for (q in requests) expect_identical(q[["dimensionCallSetPage"]], "1")
  expect_setequal(result$callSetDbId, c("s3", "s4"))
  expect_setequal(result$variantDbId, paste0("v", 1:4))
})

test_that("brapi_allele_matrix reports HTTP errors with the server's message", {
  local_mocked_bindings(
    req_perform = function(req) {
      q <- httr2::url_parse(req$url)$query
      expect_identical(q[["variantSetDbId"]], "vs1")
      expect_identical(q[["dimensionVariantPage"]], "0")
      expect_identical(q[["dimensionCallSetPage"]], "0")
      httr2::response(
        status_code = 401L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(
          '{"metadata": {"status": [{"messageType": "ERROR",
            "message": "You must login"}]}}'
        )
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  err <- expect_error(
    brapi_allele_matrix(con, variantSetDbId = "vs1"), "HTTP 401"
  )
  expect_match(conditionMessage(err), "You must login")
  expect_match(conditionMessage(err), "/allelematrix")
})

test_that("brapi_get_dosage_matrix covers every page of a paged matrix", {
  server <- mock_allele_matrix_server(function(v, cs) {
    c("0/0", "0/1", "1/1")[(v + cs) %% 3L + 1L]
  })
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org", page_size = 2L)
  dm <- expect_no_warning(suppressMessages(brapi_get_dosage_matrix(con, "vs1")))

  expect_true(is.numeric(dm))
  expect_identical(dim(dm), c(4L, 4L))
  expect_setequal(rownames(dm), paste0("s", 1:4))
  expect_setequal(colnames(dm), paste0("v", 1:4))
  expect_identical(unname(dm["s3", "v4"]), c(0, 1, 2)[(4 + 3) %% 3 + 1])
})

## The raw genotype matrix, variants in rows and call sets in columns, as
## fetch_allele_matrix_pages() returns it.
genotype_matrix <- function(..., variants, callsets) {
  matrix(c(...), nrow = length(variants), byrow = TRUE,
         dimnames = list(variants, callsets))
}

test_that("brapi_get_dosage_matrix converts genotypes into allele dosages", {
  local_mocked_bindings(
    fetch_allele_matrix_pages = function(con, query) {
      genotype_matrix("0/0", "0/1", "1/1", ".",
                      variants = c("v1", "v2"), callsets = c("s1", "s2"))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  dm <- brapi_get_dosage_matrix(con, "vs1")

  expect_true(is.matrix(dm))
  expect_identical(dim(dm), c(2L, 2L))
  expect_identical(rownames(dm), c("s1", "s2"))
  expect_identical(colnames(dm), c("v1", "v2"))
  expect_identical(unname(dm["s1", "v1"]), 0)
  expect_identical(unname(dm["s2", "v1"]), 1)
  expect_identical(unname(dm["s1", "v2"]), 2)
  expect_true(is.na(dm["s2", "v2"]))
})

test_that("brapi_get_dosage_matrix handles phased genotype separators", {
  local_mocked_bindings(
    fetch_allele_matrix_pages = function(con, query) {
      genotype_matrix("0|1", "1|1", variants = "v1", callsets = c("s1", "s2"))
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
    fetch_allele_matrix_pages = function(con, query) {
      matrix(character(), 0, 0)
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(brapi_get_dosage_matrix(con, "vs1"), "No allele matrix data")
})

test_that("brapi_get_dosage_matrix asks for expanded, delimited calls", {
  server <- mock_allele_matrix_server(function(v, cs) "0|1")
  local_mocked_bindings(req_perform = server$respond, .package = "brapiR2")

  con <- brapi_connection("https://example.org")
  dm <- suppressMessages(
    brapi_get_dosage_matrix(con, "vs1", sep = "|", unknown_string = "N")
  )

  for (q in server$requests()) {
    expect_identical(q[["variantSetDbId"]], "vs1")
    expect_identical(q[["expandHomozygotes"]], "true")
    expect_identical(q[["sepUnphased"]], "|")
    expect_identical(q[["unknownString"]], "N")
  }
  expect_true(all(dm == 1))
})

test_that("brapi_get_dosage_matrix treats a partly missing call as NA", {
  local_mocked_bindings(
    fetch_allele_matrix_pages = function(con, query) {
      genotype_matrix("./1", "0/.", "N/1", "1/1",
                      variants = "v1", callsets = paste0("s", 1:4))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  dm <- suppressMessages(
    brapi_get_dosage_matrix(con, "vs1", unknown_string = "N")
  )

  expect_true(all(is.na(dm[c("s1", "s2", "s3"), "v1"])))
  expect_identical(unname(dm["s4", "v1"]), 2)
})

test_that("brapi_get_dosage_matrix expands collapsed homozygotes", {
  local_mocked_bindings(
    fetch_allele_matrix_pages = function(con, query) {
      genotype_matrix("0", "1", "0/1", "1/2",
                      variants = "v1", callsets = paste0("s", 1:4))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  dm <- suppressMessages(brapi_get_dosage_matrix(con, "vs1"))

  expect_identical(unname(dm[, "v1"]), c(0, 2, 1, 2))
})

test_that("brapi_get_dosage_matrix infers ploidy for collapsed calls", {
  local_mocked_bindings(
    fetch_allele_matrix_pages = function(con, query) {
      genotype_matrix("0/0/1/1", "1", "0",
                      variants = "v1", callsets = paste0("s", 1:3))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  dm <- suppressMessages(brapi_get_dosage_matrix(con, "vs1"))

  expect_identical(unname(dm[, "v1"]), c(2, 4, 0))
})

test_that("brapi_get_dosage_matrix rejects non-index allele codes", {
  local_mocked_bindings(
    fetch_allele_matrix_pages = function(con, query) {
      genotype_matrix("A/T", "0/1", variants = "v1", callsets = c("s1", "s2"))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_error(
    suppressMessages(brapi_get_dosage_matrix(con, "vs1")),
    "A/T"
  )
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

test_that("brapi_get_marker_map(variantSetDbId=) reads every search page", {
  # 5 variants, all positioned; /search/markerpositions serves 2 per page.
  ids <- paste0("v", 1:5)
  respond <- function(body) {
    httr2::response(
      status_code = 200L,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw(jsonlite::toJSON(body, auto_unbox = TRUE))
    )
  }
  local_mocked_bindings(
    req_perform = function(req) {
      if (grepl("/search/markerpositions$", req$url)) {
        expect_identical(unclass(req$body$data[["variantDbIds"]]), ids)
        page <- req$body$data[["page"]] %||% 0L
        expect_identical(req$body$data[["pageSize"]], 2L)
        on_page <- ids[intersect(2L * page + 1:2, seq_along(ids))]
        return(respond(list(
          metadata = list(pagination = list(
            currentPage = page, pageSize = 2L, totalCount = 5L,
            totalPages = 3L
          )),
          result = list(data = lapply(on_page, function(v) {
            list(variantDbId = v, mapDbId = "map1",
                 linkageGroupName = "1", position = 1L)
          }))
        )))
      }
      q <- httr2::url_parse(req$url)$query
      expect_identical(q[["page"]], "0")
      if (grepl("/variants\\?", req$url)) {
        expect_identical(q[["variantSetDbId"]], "vs1")
        data <- lapply(ids, function(v) list(variantDbId = v))
      } else {
        expect_match(req$url, "/maps\\?")
        data <- list(list(mapDbId = "map1", mapName = "Map One",
                          type = "Genetic", unit = "cM"))
      }
      respond(list(
        metadata = list(pagination = list(totalPages = 1L)),
        result = list(data = data)
      ))
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org", page_size = 2L)
  markers <- expect_no_warning(
    brapi_get_marker_map(con, variantSetDbId = "vs1")
  )
  expect_setequal(markers$variantDbId, ids)
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

test_that("a null genotype mid-row stays in its own cell", {
  seen <- new.env(parent = emptyenv())
  seen$urls <- character()
  local_mocked_bindings(
    req_perform = function(req) {
      seen$urls <- c(seen$urls, req$url)
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(paste0(
          '{"result": {',
          '"pagination": [',
          '{"dimension": "VARIANTS", "totalPages": 1},',
          '{"dimension": "CALLSETS", "totalPages": 1}],',
          '"variantDbIds": ["v1", "v2"],',
          '"callSetDbIds": ["s1", "s2", "s3"],',
          '"dataMatrices": [{"dataMatrixName": "Genotype",',
          ' "dataMatrixAbbreviation": "GT",',
          ' "dataMatrix": [["0/0", null, "1/1"], ["0/1", "0/1", "0/0"]]}]',
          "}}"
        ))
      )
    },
    .package = "brapiR2"
  )
  con <- brapi_connection("https://example.org")

  am <- brapi_allele_matrix(con, variantSetDbId = "vs1")
  gt <- stats::setNames(am$genotype, paste(am$variantDbId, am$callSetDbId))
  expect_identical(gt[["v1 s1"]], "0/0")
  expect_identical(gt[["v1 s2"]], NA_character_)
  expect_identical(gt[["v1 s3"]], "1/1")
  expect_identical(gt[["v2 s3"]], "0/0")

  dm <- suppressMessages(brapi_get_dosage_matrix(con, "vs1"))
  expect_true(is.na(dm["s2", "v1"]))
  expect_identical(unname(dm["s3", "v1"]), 2)
  expect_identical(unname(dm["s1", "v1"]), 0)

  q <- lapply(seen$urls, function(u) httr2::url_parse(u)$query)
  expect_identical(q[[1]][["variantSetDbId"]], "vs1")
  expect_identical(q[[2]][["variantSetDbId"]], "vs1")
  expect_identical(q[[2]][["expandHomozygotes"]], "true")
  expect_true(all(grepl("/brapi/v2/allelematrix?", seen$urls, fixed = TRUE)))
})
