# Parallel Batch Fetching

Fetches data from multiple BrAPI endpoints or IDs in parallel using the
`furrr` package. Useful for retrieving data across many studies, trials,
or germplasm records simultaneously.

## Usage

``` r
brapi_fetch_parallel(con, .fn, ids, .workers = 4L, ...)
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

  Integer. Number of parallel workers. Default 4.

- ...:

  Additional arguments passed to `.fn`.

## Value

A tibble with results from all IDs combined.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
study_ids <- c("study1", "study2", "study3")
all_data <- brapi_fetch_parallel(con, brapi_study_data, study_ids)
#> ℹ Fetching 3 items across 4 workers...
#> ✔ Fetched 6 rows from 3 sources.
# }
```
