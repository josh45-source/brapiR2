# Internal: Build a BrAPI Request

Constructs an httr2 request object with the correct base URL, path,
authentication headers, and timeout.

## Usage

``` r
brapi_req(con, endpoint)
```

## Arguments

- con:

  A `brapi_con` object.

- endpoint:

  Character. The API endpoint path (e.g. "/programs").

## Value

An httr2 request object.
