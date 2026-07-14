# List People

List People

## Usage

``` r
brapi_people(con, ...)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.

## Value

A tibble with one row per person.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_people(con)
#> # A tibble: 12 × 11
#>    additionalInfo description emailAddress externalReferences firstName lastName
#>    <list>         <chr>       <chr>        <list>             <chr>     <chr>   
#>  1 <NULL>         List Owner… bob@bob.com  <NULL>             Bob       Roberts…
#>  2 <named list>   Example Pe… bob@bob.com  <list [1]>         Bob       Roberts…
#>  3 <named list>   Example Pe… rob@bob.com  <list [1]>         Rob       Roberts…
#>  4 <NULL>         Program Di… bob@bob.com  <NULL>             Bob       Roberts…
#>  5 <NULL>         Program Di… bob@bob.com  <NULL>             Bob       Roberts…
#>  6 <NULL>         Program Di… bob@bob.com  <NULL>             Bob       Roberts…
#>  7 <NULL>         Breeder     d.breeder@b… <NULL>             Dave      Breeder 
#>  8 <NULL>         Breeder     e.breeder@b… <NULL>             Eve       Breeder 
#>  9 <NULL>         Breeder     e.breeder@b… <NULL>             Eve       Breeder 
#> 10 <NULL>         Breeder     a.breeder@b… <NULL>             Alan      Breeder 
#> 11 <NULL>         Breeder     b.breeder@b… <NULL>             Bonnie    Breeder 
#> 12 <NULL>         Breeder     c.breeder@b… <NULL>             Chris     Breeder 
#> # ℹ 5 more variables: mailingAddress <chr>, middleName <chr>,
#> #   phoneNumber <chr>, userID <chr>, personDbId <chr>
# }
```
