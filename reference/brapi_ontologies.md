# List Ontologies

Retrieves the ontologies registered on the server: metadata about each
ontology (name, version, authors, description, ...), not the trait terms
that belong to it.
[`brapi_traits()`](https://josh45-source.github.io/brapiR2/reference/brapi_traits.md),
[`brapi_scales()`](https://josh45-source.github.io/brapiR2/reference/brapi_scales.md),
[`brapi_methods()`](https://josh45-source.github.io/brapiR2/reference/brapi_methods.md),
and
[`brapi_observation_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_variables.md)
each carry an ontology reference back to one of these records.

## Usage

``` r
brapi_ontologies(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per ontology.

## See also

[`brapi_ontology()`](https://josh45-source.github.io/brapiR2/reference/brapi_ontology.md)
for a single ontology by ID;
[`brapi_traits()`](https://josh45-source.github.io/brapiR2/reference/brapi_traits.md),
[`brapi_scales()`](https://josh45-source.github.io/brapiR2/reference/brapi_scales.md),
[`brapi_methods()`](https://josh45-source.github.io/brapiR2/reference/brapi_methods.md),
and
[`brapi_observation_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_variables.md)
for the records that reference these ontologies.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_ontologies(con)
#> # A tibble: 105 × 10
#>    additionalInfo   externalReferences authors copyright      description       
#>    <list>           <lgl>              <chr>   <chr>          <chr>             
#>  1 <NULL>           NA                 NA      NA             NA                
#>  2 <NULL>           NA                 NA      NA             NA                
#>  3 <NULL>           NA                 NA      NA             NA                
#>  4 <NULL>           NA                 NA      NA             NA                
#>  5 <NULL>           NA                 NA      NA             NA                
#>  6 <NULL>           NA                 NA      NA             NA                
#>  7 <named list [1]> NA                 Bob     2017 brapi.org Ontology.org      
#>  8 <named list [1]> NA                 Bob     2017 brapi.org Custom Maize Onto…
#>  9 <named list [1]> NA                 Bob     2017 brapi.org Custom Pawpaw Ont…
#> 10 <NULL>           NA                 NA      NA             NA                
#> # ℹ 95 more rows
#> # ℹ 5 more variables: documentationURL <chr>, licence <chr>,
#> #   ontologyName <chr>, version <chr>, ontologyDbId <chr>
# }
```
