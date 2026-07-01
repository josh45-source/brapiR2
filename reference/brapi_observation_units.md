# List Observation Units

List Observation Units

## Usage

``` r
brapi_observation_units(con, studyDbId = NULL, ...)
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

A tibble with one row per observation unit (plot/plant/sample).
