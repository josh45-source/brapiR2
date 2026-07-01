# List Breeding Programs

Retrieves a list of breeding programs from the BrAPI server.

## Usage

``` r
brapi_programs(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters passed to the API (e.g.
  `commonCropName = "rice"`, `programName = "IRRI"`).

## Value

A tibble with one row per program.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
brapi_programs(con)
brapi_programs(con, commonCropName = "rice")
} # }
```
