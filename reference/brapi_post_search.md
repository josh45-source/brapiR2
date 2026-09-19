# Call Any BrAPI Search Endpoint

The companion to
[`brapi_get()`](https://josh45-source.github.io/brapiR2/reference/brapi_get.md)
for the POST `/search/{entity}` endpoints, which take a filter body
rather than query parameters and may run asynchronously. Use it for
search endpoints brapiR2 does not wrap, or for filter fields a named
search function does not expose.

## Usage

``` r
brapi_post_search(
  con,
  endpoint,
  body = list(),
  poll_interval = 2,
  max_polls = 30L
)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- endpoint:

  Character. The search endpoint, with or without a leading slash (for
  example `"/search/germplasm"`).

- body:

  Named list. The search request body. Filter fields are sent as JSON
  arrays, as BrAPI expects, even when you supply a single value.

- poll_interval:

  Numeric. Seconds between polling attempts for an asynchronous search.
  Default 2.

- max_polls:

  Integer. Maximum polling attempts before giving up. Default 30.

## Value

A tibble of search results.

## Asynchronous searches

A server may answer immediately with the results, or with HTTP 202 and a
`searchResultsDbId` to be polled until the results are ready. Both are
handled here; the polling happens inside the call and you get the
finished results either way.

## Return shape

As with
[`brapi_get()`](https://josh45-source.github.io/brapiR2/reference/brapi_get.md),
the response passes through the same parser the named functions use. A
well-formed BrAPI result returns one row per record; an unusual one may
need reshaping yourself.

## See also

[`brapi_get()`](https://josh45-source.github.io/brapiR2/reference/brapi_get.md)
for the GET endpoints.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_post_search(con, "/search/germplasm",
                  body = list(germplasmNames = "Tomatillo Fantastico"))
#> # A tibble: 3 × 32
#>   additionalInfo   externalReferences accessionNumber acquisitionDate
#>   <list>           <list>             <chr>           <chr>          
#> 1 <named list [1]> <list [1]>         A0000001        2000-04-09     
#> 2 <named list [1]> <list [1]>         A0000002        2000-04-09     
#> 3 <named list [1]> <list [1]>         A0000003        2000-04-09     
#> # ℹ 28 more variables: biologicalStatusOfAccessionCode <chr>,
#> #   biologicalStatusOfAccessionDescription <chr>, breedingMethodDbId <chr>,
#> #   breedingMethodName <chr>, collection <chr>, commonCropName <chr>,
#> #   countryOfOriginCode <chr>, defaultDisplayName <chr>,
#> #   documentationURL <chr>, donors <list>, genus <chr>, germplasmName <chr>,
#> #   germplasmOrigin <list>, germplasmPUI <chr>, germplasmPreprocessing <chr>,
#> #   instituteCode <chr>, instituteName <chr>, pedigree <chr>, …
# }
```
