# Validate a Connection Object

Checks that the input is a valid `brapi_con`. Used internally at the
start of every exported function.

## Usage

``` r
validate_con(con)
```

## Arguments

- con:

  Object to validate.

## Value

Invisibly returns `con` if valid; throws an error otherwise.
