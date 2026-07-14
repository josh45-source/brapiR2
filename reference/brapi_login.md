# Login to a BrAPI Server with Username and Password

Authenticates using the BrAPI `/token` endpoint and returns an updated
connection object with the Bearer token set.

## Usage

``` r
brapi_login(con, username, password)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- username:

  Character. Your username.

- password:

  Character. Your password.

## Value

A new `brapi_con` object with the token populated.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
con <- brapi_login(con, "brapi_reader", "brapi_reader")
#> ✔ Logged in to <https://test-server.brapi.org>
con
#> 
#> ── BrAPI Connection 
#> • Server: <https://test-server.brapi.org>
#> • Version: v2
#> • Auth: ✓ authenticated
#> • Page size: 1000
#> • Timeout: 120s
#> • Cache: disabled
# }
```
