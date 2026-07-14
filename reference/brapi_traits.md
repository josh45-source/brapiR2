# List Traits

List Traits

## Usage

``` r
brapi_traits(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per trait.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_traits(con)
#> # A tibble: 6 × 16
#>   additionalInfo externalReferences alternativeAbbreviations attribute
#>   <lgl>          <lgl>              <lgl>                    <chr>    
#> 1 NA             NA                 NA                       height   
#> 2 NA             NA                 NA                       height   
#> 3 NA             NA                 NA                       height   
#> 4 NA             NA                 NA                       height   
#> 5 NA             NA                 NA                       yield    
#> 6 NA             NA                 NA                       color    
#> # ℹ 12 more variables: attributePUI <chr>, entity <chr>, entityPUI <chr>,
#> #   mainAbbreviation <chr>, ontologyReference <list>, status <chr>,
#> #   synonyms <lgl>, traitClass <chr>, traitDescription <chr>, traitName <chr>,
#> #   traitPUI <chr>, traitDbId <chr>
# }
```
