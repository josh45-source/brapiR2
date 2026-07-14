# List Seasons

List Seasons

## Usage

``` r
brapi_seasons(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters (e.g. `year`).

## Value

A tibble with one row per season.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_seasons(con)
#> # A tibble: 10 × 3
#>    seasonDbId  seasonName  year
#>    <chr>       <chr>      <int>
#>  1 fall_2011   fall        2011
#>  2 fall_2012   fall        2012
#>  3 fall_2013   fall        2013
#>  4 spring_2012 spring      2012
#>  5 spring_2013 spring      2013
#>  6 summer_2012 summer      2012
#>  7 summer_2013 summer      2013
#>  8 winter_2012 winter      2012
#>  9 winter_2013 winter      2013
#> 10 winter_2014 winter      2014
# }
```
