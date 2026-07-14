# Get Allele Matrix

Retrieves genotype calls from the `/allelematrix` endpoint and returns a
tidy tibble with one row per (variant, callSet) combination. The
`/allelematrix` response has a unique structure (2-D pagination, no
`result$data` envelope) so it cannot use the generic `brapi_get()`.

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

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_allele_matrix(con, variantSetDbId = "variantset1")
#> # A tibble: 260 × 3
#>    variantDbId callSetDbId genotype
#>    <chr>       <chr>       <chr>   
#>  1 variant01   callset01   0/0     
#>  2 variant01   callset02   1/0     
#>  3 variant01   callset03   1/0     
#>  4 variant01   callset04   1/0     
#>  5 variant01   callset05   1/0     
#>  6 variant01   callset06   0/0     
#>  7 variant01   callset07   1/0     
#>  8 variant01   callset08   .       
#>  9 variant01   callset09   1/0     
#> 10 variant01   callset10   1/0     
#> # ℹ 250 more rows
# }
```
