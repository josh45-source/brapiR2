# Get a Single Program by ID

Get a Single Program by ID

## Usage

``` r
brapi_program(con, programDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- programDbId:

  Character. The unique program identifier.

## Value

A single-row tibble with program details.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_program(con, "program1")
#> # A tibble: 1 × 12
#>   additionalInfo externalReferences abbreviation commonCropName documentationURL
#>   <list>         <list>             <chr>        <chr>          <chr>           
#> 1 <named list>   <list [1]>         P1           Tomatillo      https://brapi.o…
#> # ℹ 7 more variables: leadPersonDbId <chr>, leadPersonName <chr>,
#> #   objective <chr>, programName <chr>, programType <chr>,
#> #   fundingInformation <chr>, programDbId <chr>
# }
```
