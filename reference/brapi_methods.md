# List Methods

List Methods

## Usage

``` r
brapi_methods(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per measurement method.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_methods(con)
#> # A tibble: 5 × 10
#>   additionalInfo externalReferences bibliographicalReference description formula
#>   <lgl>          <lgl>              <chr>                    <chr>       <chr>  
#> 1 NA             NA                 google.com               Standard r… a^2 + …
#> 2 NA             NA                 google.com               Standard r… a^2 + …
#> 3 NA             NA                 google.com               Standard r… a^2 + …
#> 4 NA             NA                 brapi.org                Weight on … kg per…
#> 5 NA             NA                 brapi.org                Match to a… NA     
#> # ℹ 5 more variables: methodClass <chr>, methodName <chr>, methodPUI <chr>,
#> #   ontologyReference <list>, methodDbId <chr>
# }
```
