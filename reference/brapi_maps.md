# List Genome Maps

List Genome Maps

## Usage

``` r
brapi_maps(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per genome map.

## BrAPI endpoint

`GET /maps` - see the [v2.1
specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Genotyping/GenomeMaps/Maps_GET.yaml).

Query parameters the specification defines, which may be passed through
`...`:

`mapDbId`, `mapPUI`, `scientificName`, `type`.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_maps(con)
#> # A tibble: 2 × 13
#>   additionalInfo   comments    commonCropName documentationURL linkageGroupCount
#>   <list>           <chr>       <chr>          <chr>                        <int>
#> 1 <named list [1]> This is a … Paw Paw        https://brapi.o…                 1
#> 2 <named list [1]> This is a … Paw Paw        https://brapi.o…                 1
#> # ℹ 8 more variables: mapDbId <chr>, mapName <chr>, mapPUI <chr>,
#> #   markerCount <int>, publishedDate <chr>, scientificName <chr>, type <chr>,
#> #   unit <chr>
# }
```
