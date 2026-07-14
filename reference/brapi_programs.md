# List Breeding Programs

Retrieves a list of breeding programs from the BrAPI server.

## Usage

``` r
brapi_programs(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters passed to the API (e.g.
  `commonCropName = "rice"`, `programName = "IRRI"`).

## Value

A tibble with one row per program.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_programs(con)
#> # A tibble: 3 × 12
#>   additionalInfo externalReferences abbreviation commonCropName documentationURL
#>   <list>         <list>             <chr>        <chr>          <chr>           
#> 1 <named list>   <list [1]>         P1           Tomatillo      https://brapi.o…
#> 2 <named list>   <list [1]>         P2           Tomatillo      https://brapi.o…
#> 3 <named list>   <list [1]>         P3           Paw Paw        https://brapi.o…
#> # ℹ 7 more variables: leadPersonDbId <chr>, leadPersonName <chr>,
#> #   objective <chr>, programName <chr>, programType <chr>,
#> #   fundingInformation <chr>, programDbId <chr>
brapi_programs(con, commonCropName = "rice")
#> # A tibble: 0 × 0
# }
```
