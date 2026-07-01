# Create a BrAPI Connection Object

Creates a connection object that holds server URL, authentication token,
and configuration. This object is passed as the first argument to all
`brapiR2` functions. No global state is used.

## Usage

``` r
brapi_connection(
  url,
  token = NULL,
  version = "v2",
  page_size = 1000L,
  timeout = 120
)
```

## Arguments

- url:

  Character. Base URL of the BrAPI server (e.g.
  `"https://test-server.brapi.org"`). Trailing slashes are removed.

- token:

  Character or NULL. An existing Bearer token for authentication. If
  NULL, you can authenticate later with
  [`brapi_login()`](https://josh45-source.github.io/brapiR2/reference/brapi_login.md)
  or
  [`brapi_login_oauth2()`](https://josh45-source.github.io/brapiR2/reference/brapi_login_oauth2.md).

- version:

  Character. BrAPI version path segment. Default `"v2"`.

- page_size:

  Integer. Number of records per page for paginated requests. Default
  1000.

- timeout:

  Numeric. Request timeout in seconds. Default 120.

## Value

An S3 object of class `"brapi_con"` (a named list).

## Examples

``` r
# Connect to the public BrAPI test server (no auth needed)
con <- brapi_connection("https://test-server.brapi.org")
con
#> 
#> ── BrAPI Connection 
#> • Server: <https://test-server.brapi.org>
#> • Version: v2
#> • Auth: ✗ no token
#> • Page size: 1000
#> • Timeout: 120s
#> • Cache: disabled

# Connect with an existing token
con <- brapi_connection("https://my-breedbase.org", token = "my_token_here")
```
