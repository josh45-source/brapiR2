# List Generic Lists

List Generic Lists

## Usage

``` r
brapi_lists(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters (e.g. `listType`).

## Value

A tibble with one row per list.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_lists(con)
#> # A tibble: 2 × 12
#>   additionalInfo   dateCreated   dateModified externalReferences listDescription
#>   <list>           <chr>         <chr>        <list>             <chr>          
#> 1 <named list [1]> 2011-06-14T2… 2011-06-14T… <list [1]>         Example List o…
#> 2 <named list [1]> 2011-06-14T2… 2011-06-14T… <list [1]>         Example List o…
#> # ℹ 7 more variables: listName <chr>, listOwnerName <chr>,
#> #   listOwnerPersonDbId <chr>, listSize <int>, listSource <chr>,
#> #   listType <chr>, listDbId <chr>
# }
```
