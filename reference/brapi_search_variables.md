# Search Observation Variables

Search Observation Variables

## Usage

``` r
brapi_search_variables(con, traitClasses = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- traitClasses:

  Character vector. Filter by trait class.

- ...:

  Additional search body parameters.

## Value

A tibble of matching observation variables.

## BrAPI endpoint

`POST /search/variables` - see the [v2.1
specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Phenotyping/ObservationVariables/Search_Variables_POST.yaml).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_search_variables(con, traitClasses = "agronomic")
#> # A tibble: 0 × 0
# }
```
