# List Germplasm Attributes

List Germplasm Attributes

## Usage

``` r
brapi_germplasm_attributes(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per attribute definition.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_germplasm_attributes(con)
#> # A tibble: 2 × 22
#>   additionalInfo   externalReferences commonCropName contextOfUse defaultValue
#>   <list>           <list>             <chr>          <list>       <chr>       
#> 1 <named list [1]> <list [1]>         Tomatillo      <list [2]>   10          
#> 2 <named list [1]> <list [1]>         Tomatillo      <list [2]>   20          
#> # ℹ 17 more variables: documentationURL <chr>, growthStage <chr>,
#> #   institution <chr>, language <chr>, method <list>, ontologyReference <list>,
#> #   scale <list>, scientist <chr>, status <chr>, submissionTimestamp <chr>,
#> #   synonyms <list>, trait <list>, attributeCategory <chr>,
#> #   attributeDescription <chr>, attributeName <chr>, attributePUI <chr>,
#> #   attributeDbId <chr>
# }
```
