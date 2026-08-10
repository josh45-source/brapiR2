# Search Marker Positions

The `/markerpositions` GET filter (see
[`brapi_marker_positions()`](https://josh45-source.github.io/brapiR2/reference/brapi_marker_positions.md))
takes a single `variantDbId`; this search endpoint accepts many IDs at
once, which is what
[`brapi_get_marker_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_get_marker_map.md)
uses internally when looking up positions for an entire variant set.

## Usage

``` r
brapi_search_marker_positions(
  con,
  mapDbIds = NULL,
  variantDbIds = NULL,
  linkageGroupNames = NULL,
  minPosition = NULL,
  maxPosition = NULL,
  ...
)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- mapDbIds:

  Character vector. Filter by genome map IDs.

- variantDbIds:

  Character vector. Filter by marker/variant IDs.

- linkageGroupNames:

  Character vector. Filter by linkage group names.

- minPosition:

  Integer. Minimum position, inclusive.

- maxPosition:

  Integer. Maximum position, inclusive.

- ...:

  Additional search body parameters.

## Value

A tibble of matching marker positions.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_search_marker_positions(con, variantDbIds = c("variant01", "variant02"))
#> # A tibble: 2 × 7
#>   additionalInfo   linkageGroupName mapDbId     mapName     position variantDbId
#>   <list>           <chr>            <chr>       <chr>          <int> <chr>      
#> 1 <named list [1]> Chromosome 1     genome_map1 Primary Pa…      200 variant01  
#> 2 <named list [1]> Chromosome 1     genome_map1 Primary Pa…     4000 variant02  
#> # ℹ 1 more variable: variantName <chr>
# }
```
