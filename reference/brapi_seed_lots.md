# List Seed Lots

List Seed Lots

## Usage

``` r
brapi_seed_lots(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per seed lot.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_seed_lots(con)
#> # A tibble: 2 × 17
#>   additionalInfo externalReferences amount createdDate germplasmDbId lastUpdated
#>   <list>         <list>              <dbl> <chr>       <chr>         <chr>      
#> 1 <named list>   <list [1]>            360 2020-04-02… germplasm1    2020-04-08…
#> 2 <named list>   <list [1]>             40 2020-04-02… germplasm3    2020-04-08…
#> # ℹ 11 more variables: locationDbId <chr>, locationName <chr>,
#> #   programDbId <chr>, programName <chr>, seedLotDescription <chr>,
#> #   seedLotName <chr>, sourceCollection <chr>, storageLocation <chr>,
#> #   units <chr>, contentMixture <list>, seedLotDbId <chr>
# }
```
