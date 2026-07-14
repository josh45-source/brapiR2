# List References (Chromosomes/Contigs)

List References (Chromosomes/Contigs)

## Usage

``` r
brapi_references(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per reference sequence.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_references(con)
#> # A tibble: 2 × 15
#>   additionalInfo externalReferences commonCropName isDerived length md5checksum 
#>   <list>         <lgl>              <chr>          <lgl>      <int> <chr>       
#> 1 <named list>   NA                 Tomatillo      FALSE       6010 0ba836092b9…
#> 2 <named list>   NA                 Tomatillo      FALSE       6020 0ba836092b9…
#> # ℹ 9 more variables: referenceDbId <chr>, referenceName <chr>,
#> #   referenceSetDbId <chr>, referenceSetName <lgl>, sourceAccessions <list>,
#> #   sourceDivergence <dbl>, sourceGermplasm <list>, sourceURI <chr>,
#> #   species <list>
# }
```
