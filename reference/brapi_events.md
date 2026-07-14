# List Events

List Events

## Usage

``` r
brapi_events(con, studyDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbId:

  Character or NULL. Filter by study.

- ...:

  Additional query parameters.

## Value

A tibble with one row per event.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_events(con, studyDbId = "study1")
#> # A tibble: 1 × 12
#>   additionalInfo   externalReferences date       eventDateRange   eventDbId
#>   <list>           <list>             <list>     <list>           <chr>    
#> 1 <named list [1]> <list [1]>         <list [5]> <named list [3]> event1   
#> # ℹ 7 more variables: eventDescription <chr>, eventParameters <list>,
#> #   eventType <chr>, eventTypeDbId <chr>, observationUnitDbIds <lgl>,
#> #   studyDbId <chr>, studyName <chr>
# }
```
