# List the Linkage Groups of a Genome Map

A linkage group is BrAPI's generic term for a named section of a map -
it may represent a chromosome, a scaffold, or a generic linkage group.

## Usage

``` r
brapi_map_linkage_groups(con, mapDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- mapDbId:

  Character. The unique genome map identifier.

## Value

A tibble with one row per linkage group on the map.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_map_linkage_groups(con, "genome_map1")
#> # A tibble: 1 × 4
#>   additionalInfo   linkageGroupName markerCount maxPosition
#>   <list>           <chr>                  <int>       <int>
#> 1 <named list [1]> Chromosome 1               3    50000000
# }
```
