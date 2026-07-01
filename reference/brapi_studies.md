# List Studies

Retrieves studies (occurrences/environments), optionally filtered by
trial.

## Usage

``` r
brapi_studies(con, trialDbId = NULL, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- trialDbId:

  Character or NULL. Filter by trial.

- ...:

  Additional query parameters.

## Value

A tibble with one row per study.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
brapi_studies(con)
brapi_studies(con, trialDbId = "trial_01")
} # }
```
