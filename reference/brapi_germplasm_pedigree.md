# Get Germplasm Pedigree

Get Germplasm Pedigree

## Usage

``` r
brapi_germplasm_pedigree(con, germplasmDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmDbId:

  Character. The unique germplasm identifier.

## Value

A tibble with pedigree information (parents, crosses).
