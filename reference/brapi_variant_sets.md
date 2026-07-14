# List Variant Sets (Datasets)

List Variant Sets (Datasets)

## Usage

``` r
brapi_variant_sets(con, studyDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbId:

  Character or NULL. Filter by study.

- ...:

  Additional query parameters.

## Value

A tibble with one row per variant set.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_variant_sets(con)
#> # A tibble: 1 × 11
#>   additionalInfo   externalReferences analysis   availableFormats callSetCount
#>   <list>           <list>             <list>     <list>                  <int>
#> 1 <named list [1]> <list [1]>         <list [1]> <list [3]>                 13
#> # ℹ 6 more variables: referenceSetDbId <chr>, studyDbId <chr>,
#> #   variantCount <int>, variantSetDbId <chr>, variantSetName <chr>,
#> #   metadataFields <list>
# }
```
