# Ping a BrAPI Server

Tests whether the BrAPI server is reachable and responding.

## Usage

``` r
brapi_ping(con)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

## Value

Logical. `TRUE` if the server responds, `FALSE` otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
brapi_ping(con)
} # }
```
