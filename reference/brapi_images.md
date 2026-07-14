# List Images

List Images

## Usage

``` r
brapi_images(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per image record.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_images(con)
#> # A tibble: 2 × 17
#>   additionalInfo copyright description descriptiveOntologyT…¹ externalReferences
#>   <list>         <chr>     <chr>       <list>                 <list>            
#> 1 <named list>   Copyrigh… This is an… <list [2]>             <list [1]>        
#> 2 <named list>   Copyrigh… This is an… <list [2]>             <list [1]>        
#> # ℹ abbreviated name: ¹​descriptiveOntologyTerms
#> # ℹ 12 more variables: imageFileName <chr>, imageFileSize <int>,
#> #   imageHeight <int>, imageLocation <list>, imageName <chr>,
#> #   imageTimeStamp <chr>, imageURL <chr>, imageWidth <int>, mimeType <chr>,
#> #   observationDbIds <lgl>, observationUnitDbId <chr>, imageDbId <chr>
# }
```
