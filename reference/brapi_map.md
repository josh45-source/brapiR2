# Get a Single Genome Map by ID

Get a Single Genome Map by ID

## Usage

``` r
brapi_map(con, mapDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- mapDbId:

  Character. The unique genome map identifier.

## Value

A single-row tibble with genome map details, including `type` (e.g.
`"Genetic"` or `"Physical"`) and `unit` (e.g. `"cM"` or `"bp"`).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_map(con, "genome_map1")
#> # A tibble: 1 × 13
#>   additionalInfo   comments    commonCropName documentationURL linkageGroupCount
#>   <list>           <chr>       <chr>          <chr>                        <int>
#> 1 <named list [1]> This is a … Paw Paw        https://brapi.o…                 1
#> # ℹ 8 more variables: mapDbId <chr>, mapName <chr>, mapPUI <chr>,
#> #   markerCount <int>, publishedDate <chr>, scientificName <chr>, type <chr>,
#> #   unit <chr>
# }
```
