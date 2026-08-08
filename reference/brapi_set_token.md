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

## See also

The "Handling Credentials Safely" section of
[`vignette("brapiR2")`](https://josh45-source.github.io/brapiR2/articles/brapiR2.md)
for how to keep `token` out of your script, using `.Renviron` or the
keyring package.

## Examples

``` r
con <- brapi_connection("https://test-server.brapi.org")
con <- brapi_set_token(con, "my_existing_token")
```
