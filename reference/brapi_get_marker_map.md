# Get Marker Map

Convenience function that retrieves variant positions as a tidy tibble
with columns for marker name, chromosome, and position.

## Usage

``` r
brapi_get_marker_map(con, variantSetDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbId:

  Character. The variant set to retrieve markers from.

## Value

A tibble with columns: `variantDbId`, `variantName`, `referenceName`
(chromosome), `start` (position in bp).

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
markers <- brapi_get_marker_map(con, "variantset_01")
head(markers)
} # }
```
