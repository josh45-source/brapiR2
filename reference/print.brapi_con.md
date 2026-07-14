# Print a BrAPI Connection Object

Print a BrAPI Connection Object

## Usage

``` r
# S3 method for class 'brapi_con'
print(x, ...)
```

## Arguments

- x:

  A `brapi_con` object.

- ...:

  Additional arguments (ignored).

## Value

Invisibly returns `x`.

## Examples

``` r
con <- brapi_connection("https://test-server.brapi.org")
print(con)
#> 
#> ── BrAPI Connection 
#> • Server: <https://test-server.brapi.org>
#> • Version: v2
#> • Auth: ✗ no token
#> • Page size: 1000
#> • Timeout: 120s
#> • Cache: disabled
```
