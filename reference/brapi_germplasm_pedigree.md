# Get Germplasm Pedigree

Get Germplasm Pedigree

## Usage

``` r
brapi_germplasm_pedigree(con, germplasmDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmDbId:

  Character. The unique germplasm identifier.

## Value

A tibble with pedigree information (parents, crosses).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_germplasm_pedigree(con, "germplasm1")
#> # A tibble: 1 × 15
#>   additionalInfo externalReferences breedingMethodDbId breedingMethodName
#>   <lgl>          <lgl>              <chr>              <chr>             
#> 1 NA             NA                 breeding_method1   Male Backcross    
#> # ℹ 11 more variables: crossingProjectDbId <chr>, crossingYear <int>,
#> #   defaultDisplayName <chr>, familyCode <chr>, germplasmDbId <chr>,
#> #   germplasmName <chr>, germplasmPUI <chr>, parents <lgl>,
#> #   pedigreeString <chr>, progeny <lgl>, siblings <lgl>
# }
```
