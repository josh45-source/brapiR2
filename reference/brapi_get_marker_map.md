# Get Marker Map

Convenience function that retrieves variant positions as a tidy tibble
with columns for marker name, chromosome, and position.

## Usage

``` r
brapi_get_marker_map(con, variantSetDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbId:

  Character. The variant set to retrieve markers from.

## Value

A tibble with columns: `variantDbId`, `variantName`, `referenceName`
(chromosome), `start` (position in bp).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
markers <- brapi_get_marker_map(con, "variantset1")
head(markers)
#> # A tibble: 6 × 4
#>   variantDbId variantName referenceName start
#>   <chr>       <chr>       <lgl>         <lgl>
#> 1 variant01   M1          NA            NA   
#> 2 variant02   M2          NA            NA   
#> 3 variant03   M3          NA            NA   
#> 4 variant04   M4          NA            NA   
#> 5 variant05   M5          NA            NA   
#> 6 variant06   M6          NA            NA   
# }
```
