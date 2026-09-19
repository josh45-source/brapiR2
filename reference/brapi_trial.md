# Get a Single Trial by ID

Get a Single Trial by ID

## Usage

``` r
brapi_trial(con, trialDbId)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- trialDbId:

  Character. The unique trial identifier.

## Value

A single-row tibble with trial details.

## BrAPI endpoint

`GET /trials/{trialDbId}` - see the [v2.1
specification](https://github.com/plantbreeding/BrAPI/blob/V2.1/Specification/BrAPI-Core/Trials/Trials_TrialDbId_GET_PUT.yaml).

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_trial(con, "trial1")
#> # A tibble: 1 × 4
#>   datasetPUI              license               publicReleaseDate submissionDate
#>   <chr>                   <chr>                 <chr>             <chr>         
#> 1 doi:10.15454/fake/12345 https://creativecomm… 2014-09-01        2014-01-01    
# }
```
