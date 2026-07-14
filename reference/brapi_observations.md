# List Observations

List Observations

## Usage

``` r
brapi_observations(con, studyDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbId:

  Character or NULL. Filter by study.

- ...:

  Additional query parameters.

## Value

A tibble with one row per observation (trait measurement).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_observations(con, studyDbId = "study1")
#> # A tibble: 0 × 0
# }
```
