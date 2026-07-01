# List Observation Variables

Returns the ontology of observation variables (trait + method + scale).

## Usage

``` r
brapi_observation_variables(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per variable definition.
