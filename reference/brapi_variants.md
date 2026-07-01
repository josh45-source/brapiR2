# List Variants (Markers/SNPs)

List Variants (Markers/SNPs)

## Usage

``` r
brapi_variants(con, variantSetDbId = NULL, ...)
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

A tibble with one row per variant.
