# Login to a BrAPI Server with OAuth 2.0

Performs an OAuth 2.0 authorization code flow or client credentials
flow. Returns an updated connection object with the Bearer token set.

## Usage

``` r
brapi_login_oauth2(con, client_id, client_secret, authorize_url, access_url)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- client_id:

  Character. OAuth client ID.

- client_secret:

  Character. OAuth client secret.

- authorize_url:

  Character. The authorization endpoint URL.

- access_url:

  Character. The token endpoint URL.

## Value

A new `brapi_con` object with the token populated.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
con <- brapi_login_oauth2(
  con,
  client_id = "brapi_client",
  client_secret = "brapi_secret",
  authorize_url = "https://test-server.brapi.org/brapi/v2/authorize",
  access_url = "https://test-server.brapi.org/brapi/v2/token"
)
#> ✔ Authenticated via OAuth2 to <https://test-server.brapi.org>
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
