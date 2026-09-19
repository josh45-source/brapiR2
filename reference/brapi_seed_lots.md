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

## BrAPI endpoint

`GET /seedlots` - see the [v2.1
specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Germplasm/SeedLots/SeedLots_GET_POST.yaml).

Query parameters the specification defines, which may be passed through
`...`:

`seedLotDbId`, `crossDbId`, `crossName`.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_seed_lots(con)
#> # A tibble: 2 × 17
#>   additionalInfo externalReferences amount createdDate germplasmDbId lastUpdated
#>   <list>         <list>              <dbl> <chr>       <chr>         <chr>      
#> 1 <named list>   <list [1]>            360 2020-04-02… germplasm1    2020-04-08…
#> 2 <named list>   <list [1]>             40 2020-04-02… germplasm2    2020-04-08…
#> # ℹ 11 more variables: locationDbId <chr>, locationName <chr>,
#> #   programDbId <chr>, programName <chr>, seedLotDescription <chr>,
#> #   seedLotName <chr>, sourceCollection <chr>, storageLocation <chr>,
#> #   units <chr>, contentMixture <list>, seedLotDbId <chr>
# }
```
