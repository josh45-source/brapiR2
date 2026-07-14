# Get Study Data in Wide Format

A convenience function that fetches observation units and observations
for a given study and pivots them into a wide-format tibble with one row
per observation unit and one column per trait — ready for analysis.

## Usage

``` r
brapi_study_data(con, studyDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbId:

  Character. The unique study identifier.

## Value

A wide-format tibble with columns for plot metadata and one column per
observed trait containing the measurement values.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
data <- brapi_study_data(con, "study1")
head(data)
#> # A tibble: 2 × 6
#>   observationUnitDbId observationUnitName germplasmDbId germplasmName  studyDbId
#>   <chr>               <chr>               <chr>         <chr>          <chr>    
#> 1 observation_unit1   Plot 1              germplasm1    Tomatillo Fan… study1   
#> 2 observation_unit2   Plot 2              germplasm2    Tomatillo Fan… study1   
#> # ℹ 1 more variable: `Corn Stalk Height` <list>
# }
```
