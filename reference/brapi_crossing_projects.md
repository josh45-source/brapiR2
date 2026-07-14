# List Crossing Projects

List Crossing Projects

## Usage

``` r
brapi_crossing_projects(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per crossing project.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_crossing_projects(con)
#> # A tibble: 2 × 9
#>   additionalInfo   externalReferences commonCropName crossingProjectDescription
#>   <list>           <list>             <chr>          <chr>                     
#> 1 <named list [1]> <list [1]>         Tomatillo      This is a crossing project
#> 2 <named list [1]> <list [1]>         Tomatillo      This is a crossing project
#> # ℹ 5 more variables: crossingProjectName <chr>, programDbId <chr>,
#> #   programName <chr>, potentialParents <list>, crossingProjectDbId <chr>
# }
```
