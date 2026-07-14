# List Studies

Retrieves studies (occurrences/environments), optionally filtered by
trial.

## Usage

``` r
brapi_studies(con, trialDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- trialDbId:

  Character or NULL. Filter by trial.

- ...:

  Additional query parameters.

## Value

A tibble with one row per study.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_studies(con)
#> # A tibble: 3 × 29
#>   additionalInfo   externalReferences active commonCropName contacts  
#>   <list>           <list>             <lgl>  <chr>          <list>    
#> 1 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> 2 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> 3 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> # ℹ 24 more variables: culturalPractices <chr>, dataLinks <list>,
#> #   documentationURL <chr>, endDate <chr>, environmentParameters <list>,
#> #   experimentalDesign <list>, growthFacility <list>, lastUpdate <list>,
#> #   license <chr>, locationDbId <chr>, locationName <chr>,
#> #   observationLevels <list>, observationUnitsDescription <chr>,
#> #   seasons <list>, startDate <chr>, studyCode <chr>, studyDescription <chr>,
#> #   studyName <chr>, studyPUI <chr>, studyType <chr>, trialDbId <chr>, …
brapi_studies(con, trialDbId = "trial1")
#> # A tibble: 1 × 29
#>   additionalInfo   externalReferences active commonCropName contacts  
#>   <list>           <list>             <lgl>  <chr>          <list>    
#> 1 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> # ℹ 24 more variables: culturalPractices <chr>, dataLinks <list>,
#> #   documentationURL <chr>, endDate <chr>, environmentParameters <list>,
#> #   experimentalDesign <list>, growthFacility <list>, lastUpdate <list>,
#> #   license <chr>, locationDbId <chr>, locationName <chr>,
#> #   observationLevels <list>, observationUnitsDescription <chr>,
#> #   seasons <list>, startDate <chr>, studyCode <chr>, studyDescription <chr>,
#> #   studyName <chr>, studyPUI <chr>, studyType <chr>, trialDbId <chr>, …
# }
```
