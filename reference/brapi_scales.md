# List Scales

List Scales

## Usage

``` r
brapi_scales(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per scale definition.

## See also

[`brapi_ontologies()`](https://josh45-source.github.io/brapiR2/reference/brapi_ontologies.md)
and
[`brapi_ontology()`](https://josh45-source.github.io/brapiR2/reference/brapi_ontology.md)
to resolve the ontology a scale's `ontologyDbId`/`ontologyReference`
points to.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_scales(con)
#> # A tibble: 5 × 10
#>   additionalInfo externalReferences dataType  decimalPlaces units     
#>   <lgl>          <lgl>              <chr>             <int> <chr>     
#> 1 NA             NA                 Numerical             1 cm        
#> 2 NA             NA                 Numerical             2 cm        
#> 3 NA             NA                 Numerical             1 cm        
#> 4 NA             NA                 Numerical             1 kg/hectare
#> 5 NA             NA                 Code                 NA color code
#> # ℹ 5 more variables: ontologyReference <list>, scaleName <chr>,
#> #   scalePUI <chr>, validValues <list>, scaleDbId <chr>
# }
```
