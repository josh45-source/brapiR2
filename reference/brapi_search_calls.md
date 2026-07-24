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

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_search_calls(con, variantSetDbIds = "variantset1")
#> ℹ Async search started (ID: 6b87e0e8-5ce0-4313-b89d-a42988f6f379). Polling...
#> # A tibble: 260 × 12
#>    additionalInfo callSetDbId callSetName genotype         genotypeValue
#>    <lgl>          <chr>       <chr>       <list>           <chr>        
#>  1 NA             callset01   P2          <named list [1]> 0/0          
#>  2 NA             callset01   P2          <named list [1]> 0/0          
#>  3 NA             callset01   P2          <named list [1]> 0/0          
#>  4 NA             callset01   P2          <named list [1]> 0/0          
#>  5 NA             callset01   P2          <named list [1]> 0/0          
#>  6 NA             callset01   P2          <named list [1]> 0/1          
#>  7 NA             callset01   P2          <named list [1]> 0/1          
#>  8 NA             callset01   P2          <named list [1]> 1/0          
#>  9 NA             callset01   P2          <named list [1]> 1/0          
#> 10 NA             callset01   P2          <named list [1]> 0/0          
#> # ℹ 250 more rows
#> # ℹ 7 more variables: genotypeMetadata <list>, genotype_likelihood <list>,
#> #   phaseSet <chr>, variantDbId <chr>, variantName <chr>, variantSetDbId <chr>,
#> #   variantSetName <chr>
# }
```
