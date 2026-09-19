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

## BrAPI endpoint

`GET /serverinfo` - see the [v2.1
specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/ServerInfo/ServerInfo_GET.yaml).

Query parameters the specification defines, which may be passed through
`...`:

`contentType`, `dataType`.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_ping(con)
#> ✔ Server <https://test-server.brapi.org> is reachable.
# }
```
