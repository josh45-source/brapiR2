## Mocked tests for cache.R paths that don't need network: default cache
## dir, clearing populated files, and parallel fetching.

test_that("brapi_cache_enable defaults to tools::R_user_dir()", {
  # Point R's user cache location at a temporary directory, so the test
  # never writes to the real one in the user's home.
  user_cache <- withr::local_tempdir()
  withr::local_envvar(R_USER_CACHE_DIR = user_cache)

  con <- brapi_cache_enable(brapi_connection("https://example.org"))

  expect_identical(
    normalizePath(con$cache$dir),
    normalizePath(file.path(user_cache, "R", "brapiR2"))
  )
  expect_true(dir.exists(con$cache$dir))
})

test_that("brapi_cache_clear removes populated cache files", {
  tmpdir <- file.path(tempdir(), paste0("brapi_cache_manual_", Sys.getpid()))
  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir, ttl = 3600)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  writeLines("{}", brapi_cache_path(con, "/programs", list()))
  writeLines("{}", brapi_cache_path(con, "/trials", list()))
  expect_length(list.files(tmpdir), 2L)

  brapi_cache_clear(con)
  expect_length(list.files(tmpdir), 0L)
})

test_that("brapi_cache_clear leaves files that aren't cache entries", {
  tmpdir <- tempfile("brapi_cache_shared_")
  con <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir)
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  entry <- brapi_cache_path(con, "/programs", list())
  writeLines("{}", entry)
  writeLines("x <- 1", file.path(tmpdir, "my-analysis.R"))
  writeLines("{}", file.path(tmpdir, "results.json"))
  dir.create(file.path(tmpdir, "subdir"))

  brapi_cache_clear(con)

  expect_setequal(
    list.files(tmpdir),
    c("my-analysis.R", "results.json", "subdir")
  )
})

## The bearer token a request carries, or NULL. httr2 >= 1.1.0 redacts the
## Authorization header in `req$headers`, so read it back with
## req_get_headers(); DESCRIPTION still allows httr2 1.0.0, which lacks it.
request_token <- function(req) {
  headers <- if (utils::packageVersion("httr2") >= "1.1.0") {
    httr2::req_get_headers(req, "reveal")
  } else {
    req$headers
  }
  auth <- headers$Authorization
  if (is.null(auth)) NULL else sub("^Bearer ", "", auth)
}

test_that("cache entries are not shared between different tokens", {
  tmpdir <- tempfile("brapi_cache_tokens_")
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  local_mocked_bindings(
    req_perform = function(req) {
      q <- httr2::url_parse(req$url)$query
      expect_match(req$url, "/brapi/v2/programs\\?")
      expect_identical(q[["page"]], "0")
      expect_identical(q[["pageSize"]], "1000")
      id <- request_token(req) %||% "public"
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(paste0(
          '{"metadata": {"pagination": {"totalPages": 1}},',
          ' "result": {"data": [{"programDbId": "', id, '"}]}}'
        ))
      )
    },
    .package = "brapiR2"
  )

  base <- brapi_connection("https://example.org") |>
    brapi_cache_enable(dir = tmpdir)
  alice <- brapi_set_token(base, "alice-token")
  bob <- brapi_set_token(base, "bob-token")

  expect_identical(brapi_get(alice, "/programs")$programDbId, "alice-token")
  expect_identical(brapi_get(base, "/programs")$programDbId, "public")
  expect_identical(brapi_get(bob, "/programs")$programDbId, "bob-token")
  # Each identity's entry is still served from the cache afterwards.
  expect_message(
    alice_again <- brapi_get(alice, "/programs"),
    "cached"
  )
  expect_identical(alice_again$programDbId, "alice-token")
  # The token never appears in the cache file names.
  expect_false(any(grepl("token", list.files(tmpdir))))
})

## brapi_fetch_parallel() runs under whatever future plan is active; these
## tests use a sequential one, so no workers start and the mocks apply.
local_sequential_plan <- function(env = parent.frame()) {
  old <- future::plan(future::sequential)
  withr::defer(future::plan(old), envir = env)
}

test_that("brapi_fetch_parallel fetches every ID and combines the results", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_sequential_plan()

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)
  expect_message(
    result <- brapi_fetch_parallel(con, fn, c("a", "b")),
    "2 of 2 IDs"
  )

  expect_identical(result$id, c("a", "b"))
  expect_identical(nrow(attr(result, "failed")), 0L)
})

test_that("brapi_fetch_parallel records which IDs failed and why", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_sequential_plan()
  # Expectations can't run inside future's evaluation, so the mock only
  # records each request; the checks come afterwards.
  seen <- new.env(parent = emptyenv())
  seen$requests <- list()
  local_mocked_bindings(
    req_perform = function(req) {
      id <- sub(".*/studies/", "", sub("\\?.*$", "", req$url))
      seen$requests[[length(seen$requests) + 1L]] <- list(
        id = id, query = httr2::url_parse(req$url)$query
      )
      if (id == "bad") {
        return(httr2::response(
          status_code = 404L,
          headers = list(`Content-Type` = "application/json"),
          body = charToRaw('{"Message": "No such study"}')
        ))
      }
      httr2::response(
        status_code = 200L,
        headers = list(`Content-Type` = "application/json"),
        body = charToRaw(paste0(
          '{"result": {"studyDbId": "', id, '", "studyName": "S"}}'
        ))
      )
    },
    .package = "brapiR2"
  )

  con <- brapi_connection("https://example.org")
  expect_warning(
    expect_message(
      result <- brapi_fetch_parallel(con, brapi_study, c("s1", "bad", "s3")),
      "2 of 3 IDs"
    ),
    "1 of 3 IDs failed"
  )

  expect_identical(
    vapply(seen$requests, `[[`, character(1), "id"), c("s1", "bad", "s3")
  )
  for (r in seen$requests) expect_identical(r$query[["page"]], "0")
  expect_identical(result$studyDbId, c("s1", "s3"))
  failed <- attr(result, "failed")
  expect_identical(failed$id, "bad")
  expect_match(failed$error, "HTTP 404")
})

test_that("brapi_fetch_parallel combines results whose column types differ", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_sequential_plan()

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) {
    tibble::tibble(id = id, value = if (id == "a") 1 else "x")
  }
  result <- suppressMessages(brapi_fetch_parallel(con, fn, c("a", "b")))

  expect_identical(result$id, c("a", "b"))
  expect_identical(result$value, c("1", "x"))
})

test_that("brapi_fetch_parallel warns that .workers is deprecated", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_sequential_plan()

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)

  expect_warning(
    result <- suppressMessages(
      brapi_fetch_parallel(con, fn, c("a", "b"), .workers = 2)
    ),
    "deprecated"
  )
  expect_identical(result$id, c("a", "b"))
})

test_that("brapi_fetch_parallel does not warn when nothing fails", {
  skip_if_not_installed("future")
  skip_if_not_installed("furrr")
  local_sequential_plan()

  con <- brapi_connection("https://example.org")
  fn <- function(con, id) tibble::tibble(id = id)

  expect_no_warning(
    suppressMessages(brapi_fetch_parallel(con, fn, c("a", "b")))
  )
})
