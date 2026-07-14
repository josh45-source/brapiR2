# Search Germplasm

Performs a BrAPI search for germplasm records matching the given
criteria.

## Usage

``` r
brapi_search_germplasm(
  con,
  germplasmNames = NULL,
  germplasmDbIds = NULL,
  commonCropNames = NULL,
  ...
)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmNames:

  Character vector. Filter by germplasm names.

- germplasmDbIds:

  Character vector. Filter by database IDs.

- commonCropNames:

  Character vector. Filter by crop name.

- ...:

  Additional body parameters for the search request.

## Value

A tibble of matching germplasm records.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_search_germplasm(con, commonCropNames = "Tomatillo")
#> # A tibble: 3 × 32
#>   additionalInfo   externalReferences accessionNumber acquisitionDate
#>   <list>           <list>             <chr>           <chr>          
#> 1 <named list [1]> <list [1]>         A0000001        2000-04-09     
#> 2 <named list [1]> <list [1]>         A0000002        2000-04-09     
#> 3 <named list [1]> <list [1]>         A0000003        2000-04-09     
#> # ℹ 28 more variables: biologicalStatusOfAccessionCode <chr>,
#> #   biologicalStatusOfAccessionDescription <chr>, breedingMethodDbId <chr>,
#> #   breedingMethodName <chr>, collection <chr>, commonCropName <chr>,
#> #   countryOfOriginCode <chr>, defaultDisplayName <chr>,
#> #   documentationURL <chr>, donors <list>, genus <chr>, germplasmName <chr>,
#> #   germplasmOrigin <list>, germplasmPUI <chr>, germplasmPreprocessing <chr>,
#> #   instituteCode <chr>, instituteName <chr>, pedigree <chr>, …
# }
```
