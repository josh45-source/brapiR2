# Get a Single Study by ID

Get a Single Study by ID

## Usage

``` r
brapi_study(con, studyDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbId:

  Character. The unique study identifier.

## Value

A single-row tibble with study metadata.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_study(con, "study1")
#> # A tibble: 1 × 8
#>   dataFormat    description     fileFormat name  provenance scientificType url  
#>   <chr>         <chr>           <chr>      <chr> <chr>      <chr>          <chr>
#> 1 Image Archive Raw drone imag… applicati… imag… Image Pro… Environmental  http…
#> # ℹ 1 more variable: version <chr>
# }
```
