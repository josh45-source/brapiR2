# Get Study Data in Wide Format

A convenience function that fetches observation units and observations
for a given study and pivots them into a wide-format tibble with one row
per observation unit and one column per trait — ready for analysis.

## Usage

``` r
brapi_study_data(con, studyDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- studyDbId:

  Character. The unique study identifier.

## Value

A wide-format tibble with columns for plot metadata and one column per
observed trait containing the measurement values.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
data <- brapi_study_data(con, "study_01")
head(data)
} # }
```
