# Search Variants

Search Variants

## Usage

``` r
brapi_search_variants(con, variantSetDbIds = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbIds:

  Character vector. Filter by variant set IDs.

- ...:

  Additional search body parameters.

## Value

A tibble of matching variants.
