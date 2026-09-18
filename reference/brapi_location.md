# Get a Single Location by ID

Get a Single Location by ID

## Usage

``` r
brapi_location(con, locationDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- locationDbId:

  Character. The unique location identifier.

## Value

A single-row tibble with location metadata, including coordinates where
the server provides them.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_location(con, "location_01")
#> # A tibble: 1 × 21
#>   additionalInfo   externalReferences abbreviation coordinateDescription        
#>   <list>           <list>             <chr>        <chr>                        
#> 1 <named list [1]> <list [1]>         L1           Northwest corner of greenhou…
#> # ℹ 17 more variables: coordinateUncertainty <chr>, coordinates <list>,
#> #   countryCode <chr>, countryName <chr>, documentationURL <chr>,
#> #   environmentType <chr>, exposure <chr>, instituteAddress <chr>,
#> #   instituteName <chr>, locationName <chr>, locationType <chr>,
#> #   siteStatus <chr>, slope <chr>, topography <chr>, parentLocationDbId <chr>,
#> #   parentLocationName <chr>, locationDbId <chr>
# }
```
