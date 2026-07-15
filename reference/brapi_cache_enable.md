# Enable Response Caching

Returns a new connection object with caching enabled. Cached responses
are stored as JSON files in the specified directory, keyed by URL and
query parameters.

## Usage

``` r
brapi_cache_enable(con, dir = NULL, ttl = 3600)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- dir:

  Character. Directory to store cached responses. Defaults to a user
  cache directory via
  [`rappdirs::user_cache_dir()`](https://rappdirs.r-lib.org/reference/user_cache_dir.html).

- ttl:

  Numeric. Time-to-live for cached entries in seconds. Default 3600 (1
  hour).

## Value

A new `brapi_con` object with caching configured.

## Examples

``` r
con <- brapi_connection("https://test-server.brapi.org")
con <- brapi_cache_enable(con, dir = tempdir(), ttl = 7200)
#> ✔ Caching enabled at /tmp/RtmpJk0aJ4 (TTL: 7200s)
con
#> 
#> ── BrAPI Connection 
#> • Server: <https://test-server.brapi.org>
#> • Version: v2
#> • Auth: ✗ no token
#> • Page size: 1000
#> • Timeout: 120s
#> • Cache: enabled (/tmp/RtmpJk0aJ4)
```
