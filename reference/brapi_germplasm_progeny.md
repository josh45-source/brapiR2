# Get Germplasm Progeny

Get Germplasm Progeny

## Usage

``` r
brapi_germplasm_progeny(con, germplasmDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmDbId:

  Character. The unique germplasm identifier.

## Value

A single-row tibble of the germplasm's pedigree node, with `progeny` as
a list-column of a tidy tibble of descendants. See
[`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md),
which this function calls.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_germplasm_progeny(con, "germplasm1")
#> # A tibble: 1 × 15
#>   additionalInfo externalReferences breedingMethodDbId breedingMethodName
#>   <lgl>          <lgl>              <chr>              <chr>             
#> 1 NA             NA                 breeding_method1   Male Backcross    
#> # ℹ 11 more variables: crossingProjectDbId <chr>, crossingYear <int>,
#> #   defaultDisplayName <chr>, familyCode <chr>, germplasmDbId <chr>,
#> #   germplasmName <chr>, germplasmPUI <chr>, parents <list>,
#> #   pedigreeString <chr>, progeny <list>, siblings <list>
# }
```
