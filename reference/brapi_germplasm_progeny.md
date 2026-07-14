# Get Germplasm Progeny

Get Germplasm Progeny

## Usage

``` r
brapi_germplasm_progeny(con, germplasmDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmDbId:

  Character. The unique germplasm identifier.

## Value

A tibble with progeny information.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_germplasm_progeny(con, "germplasm1")
#> # A tibble: 1 × 3
#>   germplasmDbId germplasmName        progeny   
#>   <chr>         <chr>                <list>    
#> 1 germplasm1    Tomatillo Fantastico <list [1]>
# }
```
