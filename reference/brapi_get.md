# Call Any BrAPI GET Endpoint

The named functions in brapiR2 cover 32 of the 36 BrAPI v2.1 entities.
This is the layer beneath them, for endpoints brapiR2 does not wrap, for
servers with non-standard extensions, and for query parameters a named
function does not expose. Pagination, caching, authentication and error
reporting work exactly as they do for the named functions.

## Usage

``` r
brapi_get(con, endpoint, query = list(), max_pages = Inf)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- endpoint:

  Character. The endpoint path, with or without a leading slash (for
  example `"/programs"` or `"commoncropnames"`). The base URL, BrAPI
  path and version come from `con`.

- query:

  Named list. Query parameters to append to the URL. `pageSize` defaults
  to the connection's page size; `page` is managed by the pagination
  loop and should not be set here.

- max_pages:

  Numeric. Stop after this many pages instead of fetching all of them.
  `Inf`, the default, fetches everything. A production server may hold
  hundreds of thousands of records, so a small value is useful for
  looking at what an unfamiliar server holds. A truncated result is
  never cached.

## Value

A tibble of results, or an empty tibble if the endpoint returned no
data.

## Return shape

The response passes through the same parser the named functions use, so
a well-formed BrAPI collection returns one row per record. An endpoint
returning something the parser does not recognise may come back with
list-columns or a shape you need to reshape yourself. The named
functions are the better choice wherever one exists.

## See also

[`brapi_post_search()`](https://josh45-source.github.io/brapiR2/reference/brapi_post_search.md)
for the POST search endpoints.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")

# An endpoint brapiR2 does not wrap
brapi_get(con, "/commoncropnames")
#> # A tibble: 3 × 1
#>   value    
#>   <chr>    
#> 1 Tomatillo
#> 2 Paw Paw  
#> 3 Maize    

# A query parameter no named function exposes
brapi_get(con, "/studies", query = list(active = "true"))
#> # A tibble: 3 × 29
#>   additionalInfo   externalReferences active commonCropName contacts  
#>   <list>           <list>             <lgl>  <chr>          <list>    
#> 1 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> 2 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> 3 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> # ℹ 24 more variables: culturalPractices <chr>, dataLinks <list>,
#> #   documentationURL <chr>, endDate <chr>, environmentParameters <list>,
#> #   experimentalDesign <list>, growthFacility <list>, lastUpdate <list>,
#> #   license <chr>, locationDbId <chr>, locationName <chr>,
#> #   observationLevels <list>, observationUnitsDescription <chr>,
#> #   seasons <list>, startDate <chr>, studyCode <chr>, studyDescription <chr>,
#> #   studyName <chr>, studyPUI <chr>, studyType <chr>, trialDbId <chr>, …
# }
```
