# ---- Response Caching ----


#' Enable Response Caching
#'
#' Returns a new connection object with caching enabled. Cached responses
#' are stored as JSON files in the specified directory, keyed by URL and
#' query parameters.
#'
#' @inheritParams brapi_shared_params
#' @param dir Character. Directory to store cached responses.
#'   Defaults to a user cache directory via `rappdirs::user_cache_dir()`.
#' @param ttl Numeric. Time-to-live for cached entries in seconds.
#'   Default 3600 (1 hour).
#'
#' @return A new `brapi_con` object with caching configured.
#'
#' @examples
#' con <- brapi_connection("https://test-server.brapi.org")
#' con <- brapi_cache_enable(con, dir = tempdir(), ttl = 7200)
#' con
#'
#' @export
brapi_cache_enable <- function(con, dir = NULL, ttl = 3600) {
  validate_con(con)

  if (is.null(dir)) {
    if (!requireNamespace("rappdirs", quietly = TRUE)) {
      cli_abort(c(
        "Install {.pkg rappdirs} to use the default cache dir,",
        "i" = "or specify {.arg dir} directly."
      ))
    }
    dir <- rappdirs::user_cache_dir("brapiR2")
  }

  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  con$cache <- list(dir = dir, ttl = ttl)
  cli_alert_success("Caching enabled at {.path {dir}} (TTL: {ttl}s)")
  con
}


#' Clear the Response Cache
#'
#' Removes all cached responses from the cache directory.
#'
#' @param con A [brapi_connection()] object with caching enabled.
#'
#' @return Invisibly returns `con`.
#'
#' @examples
#' con <- brapi_connection("https://test-server.brapi.org")
#' con <- brapi_cache_enable(con, dir = tempdir())
#' brapi_cache_clear(con)
#'
#' @export
brapi_cache_clear <- function(con) {
  validate_con(con)

  if (is.null(con$cache)) {
    cli_alert_warning("Caching is not enabled on this connection.")
    return(invisible(con))
  }

  files <- list.files(con$cache$dir, full.names = TRUE)
  if (length(files) > 0) {
    file.remove(files)
    cli_alert_success("Cleared {length(files)} cached response(s).")
  } else {
    cli_alert_info("Cache is already empty.")
  }
  invisible(con)
}


#' Parallel Batch Fetching
#'
#' Fetches data from multiple BrAPI endpoints or IDs in parallel using
#' the `furrr` package. Useful for retrieving data across many studies,
#' trials, or germplasm records simultaneously.
#'
#' This function uses whatever `future` plan is already active when it is
#' called, and does not set or restore one itself. If you have not called
#' [future::plan()], `furrr::future_map_dfr()` falls back to
#' `future::sequential`, so nothing runs in parallel until you set a plan
#' yourself - call `future::plan(future::multisession, workers = N)` before
#' this function to fetch in parallel, and `future::plan(future::sequential)`
#' afterwards to shut the workers back down. Per the future package's
#' best-practices vignette, choosing the parallel backend is the caller's
#' decision: a package that sets and restores a plan on every call still
#' mutates session-wide state the caller did not ask it to touch, and can
#' silently replace a backend they configured deliberately.
#'
#' @inheritParams brapi_shared_params
#' @param .fn A brapiR2 function to call for each item
#'   (e.g. `brapi_study_data`).
#' @param ids Character vector. A set of IDs to iterate over.
#' @param .workers Deprecated. No longer used - the parallel backend is now
#'   the caller's choice, set via [future::plan()] before calling this
#'   function. Supplying a non-`NULL` value emits a deprecation warning and
#'   otherwise has no effect.
#' @param ... Additional arguments passed to `.fn`.
#'
#' @return A tibble with results from all IDs combined.
#'
#' @examples
#' \donttest{
#' con <- brapi_connection("https://test-server.brapi.org")
#' study_ids <- c("study1", "study2", "study3")
#'
#' # Set the parallel backend yourself before calling; brapi_fetch_parallel()
#' # uses whatever plan is active rather than setting one for you.
#' future::plan(future::multisession, workers = 2)
#' all_data <- brapi_fetch_parallel(con, brapi_study_data, study_ids)
#' future::plan(future::sequential) # shut the workers back down when done
#' }
#'
#' @export
brapi_fetch_parallel <- function(con, .fn, ids, .workers = NULL, ...) {
  validate_con(con)

  if (!requireNamespace("furrr", quietly = TRUE) ||
        !requireNamespace("future", quietly = TRUE)) {
    cli_abort("Install {.pkg furrr} and {.pkg future} for parallel fetching.")
  }

  if (!is.null(.workers)) {
    cli_warn(c(
      "{.arg .workers} is deprecated and no longer has any effect.",
      "i" = "The parallel backend is now the caller's choice.",
      "i" = "Call {.fn future::plan} before {.fn brapi_fetch_parallel}."
    ))
  }

  cli_alert_info("Fetching {length(ids)} items...")

  results <- furrr::future_map_dfr(ids, function(id) {
    tryCatch(
      .fn(con, id, ...),
      error = function(e) {
        warn(glue("Failed for ID '{id}': {e$message}"))
        tibble()
      }
    )
  })

  cli_alert_success("Fetched {nrow(results)} rows from {length(ids)} sources.")
  results
}
