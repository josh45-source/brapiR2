# Get a Single Ontology by ID

Get a Single Ontology by ID

## Usage

``` r
brapi_ontology(con, ontologyDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ontologyDbId:

  Character. The unique ontology identifier.

## Value

A single-row tibble with ontology details.

## See also

[`brapi_ontologies()`](https://josh45-source.github.io/brapiR2/reference/brapi_ontologies.md);
[`brapi_traits()`](https://josh45-source.github.io/brapiR2/reference/brapi_traits.md),
[`brapi_scales()`](https://josh45-source.github.io/brapiR2/reference/brapi_scales.md),
[`brapi_methods()`](https://josh45-source.github.io/brapiR2/reference/brapi_methods.md),
and
[`brapi_observation_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_variables.md)
for the records that reference ontologies.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_ontology(con, "O_001")
#> # A tibble: 1 × 10
#>   additionalInfo   externalReferences authors copyright      description 
#>   <list>           <lgl>              <chr>   <chr>          <chr>       
#> 1 <named list [1]> NA                 Bob     2017 brapi.org Ontology.org
#> # ℹ 5 more variables: documentationURL <chr>, licence <chr>,
#> #   ontologyName <chr>, version <chr>, ontologyDbId <chr>
# }
```
