# Clear the Response Cache

Removes all cached responses from the cache directory.

## Usage

``` r
brapi_cache_clear(con)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object with caching enabled.

## Value

Invisibly returns `con`.

## Examples

``` r
con <- brapi_connection("https://test-server.brapi.org")
con <- brapi_cache_enable(con, dir = tempdir())
#> ✔ Caching enabled at /tmp/RtmpJz10WB (TTL: 3600s)
brapi_cache_clear(con)
#> Warning: cannot remove file '/tmp/RtmpJz10WB/bslib-36dd7d54583ca31becd9906e27a99038', reason 'Directory not empty'
#> Warning: cannot remove file '/tmp/RtmpJz10WB/downlit', reason 'Directory not empty'
#> ✔ Cleared 3 cached response(s).
```
