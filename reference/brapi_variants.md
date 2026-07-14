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

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_variants(con, variantSetDbId = "variantset1")
#> # A tibble: 20 × 23
#>    additionalInfo externalReferences alternate_bases alternateBases ciend cipos
#>    <lgl>          <lgl>              <lgl>           <lgl>          <lgl> <lgl>
#>  1 NA             NA                 NA              NA             NA    NA   
#>  2 NA             NA                 NA              NA             NA    NA   
#>  3 NA             NA                 NA              NA             NA    NA   
#>  4 NA             NA                 NA              NA             NA    NA   
#>  5 NA             NA                 NA              NA             NA    NA   
#>  6 NA             NA                 NA              NA             NA    NA   
#>  7 NA             NA                 NA              NA             NA    NA   
#>  8 NA             NA                 NA              NA             NA    NA   
#>  9 NA             NA                 NA              NA             NA    NA   
#> 10 NA             NA                 NA              NA             NA    NA   
#> 11 NA             NA                 NA              NA             NA    NA   
#> 12 NA             NA                 NA              NA             NA    NA   
#> 13 NA             NA                 NA              NA             NA    NA   
#> 14 NA             NA                 NA              NA             NA    NA   
#> 15 NA             NA                 NA              NA             NA    NA   
#> 16 NA             NA                 NA              NA             NA    NA   
#> 17 NA             NA                 NA              NA             NA    NA   
#> 18 NA             NA                 NA              NA             NA    NA   
#> 19 NA             NA                 NA              NA             NA    NA   
#> 20 NA             NA                 NA              NA             NA    NA   
#> # ℹ 17 more variables: created <lgl>, end <lgl>, filtersApplied <lgl>,
#> #   filtersFailed <lgl>, filtersPassed <lgl>, referenceBases <lgl>,
#> #   referenceName <lgl>, referenceDbId <lgl>, referenceSetName <lgl>,
#> #   referenceSetDbId <lgl>, start <lgl>, svlen <lgl>, updated <lgl>,
#> #   variantDbId <chr>, variantNames <list>, variantSetDbId <list>,
#> #   variantType <lgl>
# }
```
