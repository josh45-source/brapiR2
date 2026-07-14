# List Locations

List Locations

## Usage

``` r
brapi_locations(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters (e.g. `locationType`).

## Value

A tibble with one row per location.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_locations(con)
#> # A tibble: 3 × 21
#>   additionalInfo   externalReferences abbreviation coordinateDescription        
#>   <list>           <list>             <chr>        <chr>                        
#> 1 <named list [1]> <list [1]>         L2           Outline of the institute bre…
#> 2 <named list [1]> <list [1]>         L3           Northwest corner post        
#> 3 <named list [1]> <list [1]>         L1           Northwest corner of greenhou…
#> # ℹ 17 more variables: coordinateUncertainty <chr>, coordinates <list>,
#> #   countryCode <chr>, countryName <chr>, documentationURL <chr>,
#> #   environmentType <chr>, exposure <chr>, instituteAddress <chr>,
#> #   instituteName <chr>, locationName <chr>, locationType <chr>,
#> #   siteStatus <chr>, slope <chr>, topography <chr>, parentLocationDbId <chr>,
#> #   parentLocationName <chr>, locationDbId <chr>
# }
```
