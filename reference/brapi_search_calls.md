# Search Genotype Calls

Search Genotype Calls

## Usage

``` r
brapi_search_calls(con, variantSetDbIds = NULL, callSetDbIds = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbIds:

  Character vector. Filter by variant set IDs.

- callSetDbIds:

  Character vector. Filter by call set IDs.

- ...:

  Additional search body parameters.

## Value

A tibble of matching genotype calls.
