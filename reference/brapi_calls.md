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

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_calls(con, variantSetDbId = "variantset1")
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
