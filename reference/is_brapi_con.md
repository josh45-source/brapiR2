# Test if an Object is a BrAPI Connection

Test if an Object is a BrAPI Connection

## Usage

``` r
is_brapi_con(x)
```

## Arguments

- x:

  An object to test.

## Value

Logical.

## Examples

``` r
con <- brapi_connection("https://test-server.brapi.org")
is_brapi_con(con)
#> [1] TRUE
is_brapi_con("not a connection")
#> [1] FALSE
```
