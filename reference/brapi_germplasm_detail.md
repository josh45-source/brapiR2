# Get a Single Germplasm by ID

Get a Single Germplasm by ID

## Usage

``` r
brapi_germplasm_detail(con, germplasmDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmDbId:

  Character. The unique germplasm identifier.

## Value

A single-row tibble with germplasm details.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_germplasm_detail(con, "germplasm1")
#> # A tibble: 1 × 32
#>   additionalInfo   externalReferences accessionNumber acquisitionDate
#>   <list>           <list>             <chr>           <chr>          
#> 1 <named list [1]> <list [1]>         A0000001        2000-04-09     
#> # ℹ 28 more variables: biologicalStatusOfAccessionCode <chr>,
#> #   biologicalStatusOfAccessionDescription <chr>, breedingMethodDbId <chr>,
#> #   breedingMethodName <chr>, collection <chr>, commonCropName <chr>,
#> #   countryOfOriginCode <chr>, defaultDisplayName <chr>,
#> #   documentationURL <chr>, donors <list>, genus <chr>, germplasmName <chr>,
#> #   germplasmOrigin <list>, germplasmPUI <chr>, germplasmPreprocessing <chr>,
#> #   instituteCode <chr>, instituteName <chr>, pedigree <chr>, …
# }
```
