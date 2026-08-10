# Get Marker Map

Convenience function that retrieves marker positions on a genome map as
a tidy tibble. Positions come from the Genome Maps entity
([`brapi_marker_positions()`](https://josh45-source.github.io/brapiR2/reference/brapi_marker_positions.md)
/ `/markerpositions`), which places a marker on a named
[`brapi_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_map.md) -
genetic (cM) or physical (bp), per the map's `type` and `unit` - not
from
[`brapi_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_variants.md)'s
`start`/`referenceName`, which places a variant on a reference assembly
instead. A server may populate either, both, or neither; the two are
independent coordinate systems, not duplicates of each other.

## Usage

``` r
brapi_get_marker_map(con, variantSetDbId = NULL, mapDbId = NULL)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbId:

  Character or NULL. A variant set to retrieve marker positions for.
  Mutually exclusive with `mapDbId`.

- mapDbId:

  Character or NULL. A single genome map to retrieve all marker
  positions from. Mutually exclusive with `variantSetDbId`.

## Value

A tibble with columns `variantDbId`, `variantName`, `mapDbId`,
`mapName`, `type`, `unit`, `linkageGroupName`, and `position` - one row
per marker-map placement, so a marker on several maps appears more than
once. `type` and `unit` are joined in from
[`brapi_maps()`](https://josh45-source.github.io/brapiR2/reference/brapi_maps.md)
so a caller can tell a genetic (cM) map from a physical (bp) one.

## Details

Supply exactly one of `mapDbId` (every marker placed on that one map) or
`variantSetDbId` (positions for every variant in that set, wherever they
have been placed). The `variantSetDbId` path looks variant IDs up first
via
[`brapi_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_variants.md),
then retrieves their positions in one call via
[`brapi_search_marker_positions()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_marker_positions.md)
rather than the GET `/markerpositions` filter, which only accepts a
single `variantDbId`.

If a marker is placed on more than one map, it contributes one row per
placement - the result is never collapsed to one row per marker.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_get_marker_map(con, mapDbId = "genome_map1")
#> # A tibble: 3 × 8
#>   variantDbId variantName mapDbId  mapName type  unit  linkageGroupName position
#>   <chr>       <chr>       <chr>    <chr>   <chr> <chr> <chr>               <int>
#> 1 variant01   M1          genome_… Primar… Phys… cM    Chromosome 1          200
#> 2 variant02   M2          genome_… Primar… Phys… cM    Chromosome 1         4000
#> 3 variant03   M3          genome_… Primar… Phys… cM    Chromosome 1        60000
brapi_get_marker_map(con, variantSetDbId = "variantset1")
#> ℹ Async search started (ID: 6d85833b-53cc-4f9c-9efb-c43ed330b60c). Polling...
#> Warning: 14 of 20 variants in "variantset1" have no marker position record; returning
#> positions for the remaining 6.
#> # A tibble: 6 × 8
#>   variantDbId variantName mapDbId  mapName type  unit  linkageGroupName position
#>   <chr>       <chr>       <chr>    <chr>   <chr> <chr> <chr>               <int>
#> 1 variant01   M1          genome_… Primar… Phys… cM    Chromosome 1          200
#> 2 variant02   M2          genome_… Primar… Phys… cM    Chromosome 1         4000
#> 3 variant03   M3          genome_… Primar… Phys… cM    Chromosome 1        60000
#> 4 variant04   M4          genome_… Primar… Phys… cM    Chromosome 2          200
#> 5 variant05   M5          genome_… Primar… Phys… cM    Chromosome 2         4000
#> 6 variant06   M6          genome_… Primar… Phys… cM    Chromosome 2        60000
# }
```
