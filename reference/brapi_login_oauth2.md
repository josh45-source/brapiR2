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
if (FALSE) { # \dontrun{
con <- brapi_connection("https://ebs.example.org")
con <- brapi_login_oauth2(
  con,
  client_id = "my_client_id",
  client_secret = "my_secret",
  authorize_url = "https://auth.example.org/oauth2/authorize",
  access_url = "https://auth.example.org/oauth2/token"
)
} # }
```
