# List Samples

List Samples

## Usage

``` r
brapi_samples(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters (e.g. `studyDbId`, `germplasmDbId`,
  `observationUnitDbId`).

## Value

A tibble with one row per sample.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_samples(con)
#> # A tibble: 3 × 22
#>   additionalInfo   column externalReferences germplasmDbId observationUnitDbId
#>   <list>            <int> <list>             <chr>         <chr>              
#> 1 <named list [1]>      2 <list [1]>         germplasm2    observation_unit2  
#> 2 <named list [1]>      2 <list [1]>         germplasm1    observation_unit1  
#> 3 <named list [1]>      2 <list [1]>         germplasm3    observation_unit3  
#> # ℹ 17 more variables: plateDbId <chr>, plateName <chr>, programDbId <chr>,
#> #   row <chr>, sampleBarcode <chr>, sampleDescription <chr>,
#> #   sampleGroupDbId <chr>, sampleName <chr>, samplePUI <chr>,
#> #   sampleTimestamp <chr>, sampleType <chr>, studyDbId <chr>, takenBy <chr>,
#> #   tissueType <chr>, trialDbId <chr>, well <chr>, sampleDbId <chr>
# }
```
