# List Reference Sets (Genome Assemblies)

List Reference Sets (Genome Assemblies)

## Usage

``` r
brapi_reference_sets(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per reference set.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_reference_sets(con)
#> # A tibble: 2 × 13
#>   additionalInfo   externalReferences assemblyPUI     commonCropName description
#>   <list>           <lgl>              <chr>           <chr>          <chr>      
#> 1 <named list [1]> NA                 doi://10.12345… Tomatillo      This is an…
#> 2 <named list [1]> NA                 doi://10.22345… Tomatillo      This is an…
#> # ℹ 8 more variables: isDerived <lgl>, md5checksum <chr>,
#> #   referenceSetDbId <chr>, referenceSetName <chr>, sourceAccessions <list>,
#> #   sourceGermplasm <list>, sourceURI <chr>, species <list>
# }
```
