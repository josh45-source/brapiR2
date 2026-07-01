# List Available Endpoints

Queries the `/serverinfo` endpoint to list which BrAPI calls the server
supports, along with their HTTP methods and versions.

## Usage

``` r
brapi_endpoints(con)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

## Value

A tibble with columns for endpoint service, method(s), and version(s).

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
brapi_endpoints(con)
} # }
```
