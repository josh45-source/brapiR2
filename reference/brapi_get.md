# Internal: GET a BrAPI Endpoint with Automatic Pagination

Sends a GET request to a BrAPI endpoint and handles pagination
transparently. Returns all pages concatenated into a single tibble. When
caching is enabled on `con` (via
[`brapi_cache_enable()`](https://josh45-source.github.io/brapiR2/reference/brapi_cache_enable.md)),
the full multi-page result is stored as a JSON file keyed by URL +
sorted query parameters. Subsequent calls within the TTL window skip the
HTTP request and return the cached result.

## Usage

``` r
brapi_get(con, endpoint, query = list())
```

## Arguments

- con:

  A `brapi_con` object.

- endpoint:

  Character. The API endpoint (e.g. "/programs").

- query:

  Named list. Query parameters to append to the URL.

## Value

A tibble of results, or an empty tibble if no data.
