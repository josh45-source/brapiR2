# List Trials

Retrieves trials, optionally filtered by program.

## Usage

``` r
brapi_trials(con, programDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- programDbId:

  Character or NULL. Filter by program.

- ...:

  Additional query parameters.

## Value

A tibble with one row per trial.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
brapi_trials(con)
} # }
```
