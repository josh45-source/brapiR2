# List Genotype Calls

List Genotype Calls

## Usage

``` r
brapi_calls(con, variantSetDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbId:

  Character or NULL. Filter by variant set.

- ...:

  Additional query parameters.

## Value

A tibble with one row per genotype call.
