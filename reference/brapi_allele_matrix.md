# Get Allele Matrix

Retrieves genotype calls from the `/allelematrix` endpoint and returns a
tidy tibble with one row per (variant, callSet) combination. The
`/allelematrix` response has a unique structure (2-D pagination, no
`result$data` envelope) so it cannot use the generic
[`brapi_get()`](https://josh45-source.github.io/brapiR2/reference/brapi_get.md).

## Usage

``` r
brapi_allele_matrix(con, variantSetDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbId:

  Character or NULL. Filter by variant set.

- ...:

  Additional query parameters (e.g. `expandHomozygotes`,
  `unknownString`, `sepPhased`, `sepUnphased`).

## Value

A tibble with columns `variantDbId`, `callSetDbId`, `genotype`.
