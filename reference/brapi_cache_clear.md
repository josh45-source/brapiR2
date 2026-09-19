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
#> ✔ Caching enabled at /tmp/RtmpMlHTB9 (TTL: 3600s)
brapi_cache_clear(con)
#> Warning: cannot remove file '/tmp/RtmpMlHTB9/bslib-e9b2b13fa612f50d23e4850d93d60d01', reason 'Directory not empty'
#> Warning: cannot remove file '/tmp/RtmpMlHTB9/downlit', reason 'Directory not empty'
#> ✔ Cleared 7 cached response(s).
```
