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
#> ✔ Caching enabled at /tmp/Rtmp9WG7Xr (TTL: 3600s)
brapi_cache_clear(con)
#> Warning: cannot remove file '/tmp/Rtmp9WG7Xr/bslib-45406f9f66735000132499f277df5132', reason 'Directory not empty'
#> Warning: cannot remove file '/tmp/Rtmp9WG7Xr/downlit', reason 'Directory not empty'
#> ✔ Cleared 6 cached response(s).
```
