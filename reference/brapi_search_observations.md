# Search Observations

Search Observations

## Usage

``` r
brapi_search_observations(
  con,
  studyDbIds = NULL,
  observationVariableDbIds = NULL,
  ...
)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbIds:

  Character vector. Filter by study IDs.

- observationVariableDbIds:

  Character vector. Filter by variable IDs.

- ...:

  Additional search body parameters.

## Value

A tibble of matching observations.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_search_observations(con, studyDbIds = "study1")
#> # A tibble: 0 × 0
# }
```
