# List Call Sets (Samples with Genotype Data)

List Call Sets (Samples with Genotype Data)

## Usage

``` r
brapi_call_sets(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per call set.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_call_sets(con)
#> # A tibble: 13 × 9
#>    additionalInfo externalReferences callSetDbId callSetName created  sampleDbId
#>    <lgl>          <lgl>              <chr>       <chr>       <chr>    <chr>     
#>  1 NA             NA                 callset01   P2          2019-11… sample3   
#>  2 NA             NA                 callset02   F1-1        2019-11… sample2   
#>  3 NA             NA                 callset03   F1-2        2019-11… sample1   
#>  4 NA             NA                 callset04   F1-3        2019-11… sample3   
#>  5 NA             NA                 callset05   F1-4        2019-11… sample2   
#>  6 NA             NA                 callset06   F1-5        2019-11… sample1   
#>  7 NA             NA                 callset07   F1-6        2019-11… sample3   
#>  8 NA             NA                 callset08   F1-7        2019-11… sample2   
#>  9 NA             NA                 callset09   F1-8        2019-11… sample1   
#> 10 NA             NA                 callset10   F1-9        2019-11… sample3   
#> 11 NA             NA                 callset11   F1-10       2019-11… sample2   
#> 12 NA             NA                 callset12   F1-11       2019-11… sample1   
#> 13 NA             NA                 callset13   F1-12       2019-11… sample3   
#> # ℹ 3 more variables: studyDbId <chr>, updated <chr>, variantSetDbIds <list>
# }
```
