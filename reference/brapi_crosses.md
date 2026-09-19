# List Crosses

List Crosses

## Usage

``` r
brapi_crosses(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per cross.

## BrAPI endpoint

`GET /crosses` - see the [v2.1
specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Germplasm/Crosses/Crosses_GET_POST_PUT.yaml).

Query parameters the specification defines, which may be passed through
`...`:

`crossingProjectDbId`, `crossingProjectName`, `crossDbId`, `crossName`.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_crosses(con)
#> # A tibble: 2 × 14
#>   additionalInfo   externalReferences crossAttributes crossName     crossType 
#>   <list>           <list>             <list>          <chr>         <chr>     
#> 1 <named list [1]> <list [1]>         <list [1]>      germ1 X germ2 BIPARENTAL
#> 2 <named list [1]> <list [1]>         <list [1]>      germ1 X germ2 BIPARENTAL
#> # ℹ 9 more variables: crossingProjectDbId <chr>, crossingProjectName <chr>,
#> #   parent1 <list>, parent2 <list>, pollinationTimeStamp <chr>,
#> #   pollinationEvents <list>, plannedCrossDbId <chr>, plannedCrossName <chr>,
#> #   crossDbId <chr>
# }
```
