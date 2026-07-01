# Login to a BrAPI Server with Username and Password

Authenticates using the BrAPI `/token` endpoint and returns an updated
connection object with the Bearer token set.

## Usage

``` r
brapi_login(con, username, password)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- username:

  Character. Your username.

- password:

  Character. Your password.

## Value

A new `brapi_con` object with the token populated.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://my-breedbase.org")
con <- brapi_login(con, "my_user", "my_password")
} # }
```
