# Manually Set an Authentication Token

If you already have a token (e.g. from a web browser session), you can
set it directly without going through a login flow.

## Usage

``` r
brapi_set_token(con, token)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- token:

  Character. The Bearer token string.

## Value

A new `brapi_con` object with the token populated.

## Examples

``` r
con <- brapi_connection("https://test-server.brapi.org")
con <- brapi_set_token(con, "my_existing_token")
```
