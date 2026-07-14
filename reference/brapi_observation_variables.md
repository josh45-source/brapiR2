# List Observation Variables

Returns the ontology of observation variables (trait + method + scale).

## Usage

``` r
brapi_observation_variables(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per variable definition.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_observation_variables(con)
#> # A tibble: 4 × 19
#>   additionalInfo   externalReferences commonCropName contextOfUse defaultValue
#>   <list>           <list>             <chr>          <list>       <chr>       
#> 1 <named list [1]> <NULL>             Paw Paw        <list [2]>   NA          
#> 2 <named list [1]> <list [1]>         Paw Paw        <list [2]>   20          
#> 3 <named list [1]> <NULL>             Paw Paw        <list [1]>   NA          
#> 4 <named list [1]> <list [1]>         Maize          <list [2]>   10          
#> # ℹ 14 more variables: documentationURL <chr>, growthStage <chr>,
#> #   institution <chr>, language <chr>, method <list>, ontologyReference <list>,
#> #   scale <list>, scientist <chr>, status <chr>, submissionTimestamp <chr>,
#> #   synonyms <list>, trait <list>, observationVariableDbId <chr>,
#> #   observationVariableName <chr>
# }
```
