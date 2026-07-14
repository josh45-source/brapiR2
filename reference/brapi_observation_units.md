# List Observation Units

List Observation Units

## Usage

``` r
brapi_observation_units(con, studyDbId = NULL, ...)
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

A tibble with one row per observation unit (plot/plant/sample).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_observation_units(con, studyDbId = "study1")
#> # A tibble: 3 × 22
#>   additionalInfo   externalReferences germplasmDbId germplasmName      crossDbId
#>   <list>           <list>             <chr>         <chr>              <chr>    
#> 1 <named list [1]> <list [1]>         germplasm1    Tomatillo Fantast… cross1   
#> 2 <named list [1]> <list [1]>         germplasm2    Tomatillo Fantast… cross1   
#> 3 <named list [1]> <list [1]>         germplasm3    Tomatillo Fantast… cross2   
#> # ℹ 17 more variables: crossName <chr>, locationDbId <chr>, locationName <chr>,
#> #   observationUnitName <chr>, observationUnitPUI <chr>,
#> #   observationUnitPosition <list>, programDbId <chr>, programName <chr>,
#> #   seedLotDbId <chr>, seedLotName <chr>, studyDbId <chr>, studyName <chr>,
#> #   treatments <list>, trialDbId <chr>, trialName <chr>,
#> #   observationUnitDbId <chr>, observations <lgl>
# }
```
