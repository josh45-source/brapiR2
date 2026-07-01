# Search Germplasm

Performs a BrAPI search for germplasm records matching the given
criteria.

## Usage

``` r
brapi_search_germplasm(
  con,
  germplasmNames = NULL,
  germplasmDbIds = NULL,
  commonCropNames = NULL,
  ...
)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmNames:

  Character vector. Filter by germplasm names.

- germplasmDbIds:

  Character vector. Filter by database IDs.

- commonCropNames:

  Character vector. Filter by crop name.

- ...:

  Additional body parameters for the search request.

## Value

A tibble of matching germplasm records.
