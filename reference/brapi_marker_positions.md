# List Marker Positions

Retrieves marker placements on genome maps from `/markerpositions`. A
position here is relative to a named
[`brapi_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_map.md)
(genetic, in cM, or physical, in bp) - a different coordinate system
from
[`brapi_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_variants.md)'s
`start`/`referenceName`, which places a variant on a reference assembly
instead. A server may populate either, both, or neither; one being empty
does not imply the other is.

## Usage

``` r
brapi_marker_positions(
  con,
  mapDbId = NULL,
  variantDbId = NULL,
  linkageGroupName = NULL,
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

- mapDbId:

  Character or NULL. Filter by genome map.

- variantDbId:

  Character or NULL. Filter by a single marker/variant ID. For multiple
  IDs at once, use
  [`brapi_search_marker_positions()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_marker_positions.md)
  instead.

- linkageGroupName:

  Character or NULL. Filter by linkage group (e.g. chromosome) name.

- minPosition:

  Integer or NULL. Minimum position, inclusive.

- maxPosition:

  Integer or NULL. Maximum position, inclusive.

- ...:

  Additional query parameters.

## Value

A tibble with one row per marker placement.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_marker_positions(con, mapDbId = "genome_map1")
#> # A tibble: 3 × 7
#>   additionalInfo   linkageGroupName mapDbId     mapName     position variantDbId
#>   <list>           <chr>            <chr>       <chr>          <int> <chr>      
#> 1 <named list [1]> Chromosome 1     genome_map1 Primary Pa…      200 variant01  
#> 2 <named list [1]> Chromosome 1     genome_map1 Primary Pa…     4000 variant02  
#> 3 <named list [1]> Chromosome 1     genome_map1 Primary Pa…    60000 variant03  
#> # ℹ 1 more variable: variantName <chr>
# }
```
