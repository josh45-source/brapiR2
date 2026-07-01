# Get Server Info

Returns a tibble of BrAPI calls supported by the server. Each row is one
supported endpoint with columns for service name, HTTP methods, BrAPI
versions, and content/data types.

## Usage

``` r
brapi_server_info(con)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

## Value

A tibble of supported endpoints and their methods.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
brapi_server_info(con)
} # }
```
