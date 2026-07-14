# Get Server Info

Returns a tibble of BrAPI calls supported by the server. Each row is one
supported endpoint with columns for service name, HTTP methods, BrAPI
versions, and content/data types.

## Usage

``` r
brapi_server_info(con)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

## Value

A tibble of supported endpoints and their methods.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_server_info(con)
#> # A tibble: 148 × 5
#>    dataTypes contentTypes methods   service                             versions
#>    <list>    <list>       <list>    <chr>                               <list>  
#>  1 <chr [1]> <chr [1]>    <chr [1]> serverinfo                          <chr>   
#>  2 <chr [1]> <chr [1]>    <chr [1]> commoncropnames                     <chr>   
#>  3 <chr [1]> <chr [1]>    <chr [2]> lists                               <chr>   
#>  4 <chr [1]> <chr [1]>    <chr [2]> lists/{listDbId}                    <chr>   
#>  5 <chr [1]> <chr [1]>    <chr [1]> search/lists                        <chr>   
#>  6 <chr [1]> <chr [1]>    <chr [1]> search/lists/{searchResultsDbId}    <chr>   
#>  7 <chr [1]> <chr [1]>    <chr [2]> locations                           <chr>   
#>  8 <chr [1]> <chr [1]>    <chr [2]> locations/{locationDbId}            <chr>   
#>  9 <chr [1]> <chr [1]>    <chr [1]> search/locations                    <chr>   
#> 10 <chr [1]> <chr [1]>    <chr [1]> search/locations/{searchResultsDbI… <chr>   
#> # ℹ 138 more rows
# }
```
