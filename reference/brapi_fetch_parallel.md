# Parallel Batch Fetching

Fetches data from multiple BrAPI endpoints or IDs in parallel using the
`furrr` package. Useful for retrieving data across many studies, trials,
or germplasm records simultaneously.

## Usage

``` r
brapi_fetch_parallel(con, .fn, ids, .workers = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- .fn:

  A brapiR2 function to call for each item (e.g. `brapi_study_data`).

- ids:

  Character vector. A set of IDs to iterate over.

- .workers:

  Deprecated. No longer used - the parallel backend is now the caller's
  choice, set via
  [`future::plan()`](https://future.futureverse.org/reference/plan.html)
  before calling this function. Supplying a non-`NULL` value emits a
  deprecation warning and otherwise has no effect.

- ...:

  Additional arguments passed to `.fn`.

## Value

A tibble with results from all IDs combined.

## Details

This function uses whatever `future` plan is already active when it is
called, and does not set or restore one itself. If you have not called
[`future::plan()`](https://future.futureverse.org/reference/plan.html),
[`furrr::future_map_dfr()`](https://furrr.futureverse.org/reference/future_map.html)
falls back to
[`future::sequential`](https://future.futureverse.org/reference/sequential.html),
so nothing runs in parallel until you set a plan yourself - call
`future::plan(future::multisession, workers = N)` before this function
to fetch in parallel, and `future::plan(future::sequential)` afterwards
to shut the workers back down. Per the future package's best-practices
vignette, choosing the parallel backend is the caller's decision: a
package that sets and restores a plan on every call still mutates
session-wide state the caller did not ask it to touch, and can silently
replace a backend they configured deliberately.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
study_ids <- c("study1", "study2", "study3")

# Set the parallel backend yourself before calling; brapi_fetch_parallel()
# uses whatever plan is active rather than setting one for you.
future::plan(future::multisession, workers = 2)
all_data <- brapi_fetch_parallel(con, brapi_study_data, study_ids)
#> ℹ Fetching 3 items...
#> ! No observations found for study "study2".
#> ! No observations found for study "study3".
#> ✔ Fetched 2 rows from 3 sources.
future::plan(future::sequential) # shut the workers back down when done
# }
```
