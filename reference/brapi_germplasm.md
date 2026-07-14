# List Germplasm

List Germplasm

## Usage

``` r
brapi_germplasm(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters (e.g. `commonCropName`, `germplasmName`,
  `studyDbId`).

## Value

A tibble with one row per germplasm accession.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_germplasm(con)
#> # A tibble: 3 × 32
#>   additionalInfo   externalReferences accessionNumber acquisitionDate
#>   <list>           <list>             <chr>           <chr>          
#> 1 <named list [1]> <list [1]>         A0000002        2000-04-09     
#> 2 <named list [1]> <list [1]>         A0000003        2000-04-09     
#> 3 <named list [1]> <list [1]>         A0000001        2000-04-09     
#> # ℹ 28 more variables: biologicalStatusOfAccessionCode <chr>,
#> #   biologicalStatusOfAccessionDescription <chr>, breedingMethodDbId <chr>,
#> #   breedingMethodName <chr>, collection <chr>, commonCropName <chr>,
#> #   countryOfOriginCode <chr>, defaultDisplayName <chr>,
#> #   documentationURL <chr>, donors <list>, genus <chr>, germplasmName <chr>,
#> #   germplasmOrigin <list>, germplasmPUI <chr>, germplasmPreprocessing <chr>,
#> #   instituteCode <chr>, instituteName <chr>, pedigree <chr>, …
# }
```
