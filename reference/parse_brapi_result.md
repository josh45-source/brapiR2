# Internal: Parse BrAPI Result List into a Tibble

Takes a list of result objects (each a named list) and flattens them
into a tibble. Nested lists are kept as list-columns.

## Usage

``` r
parse_brapi_result(data)
```

## Arguments

- data:

  A list of named lists (one per record).

## Value

A tibble.
