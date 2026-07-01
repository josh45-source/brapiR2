# Internal: POST Search to a BrAPI Endpoint

Handles the BrAPI search pattern:

- POST to `/search/{entity}` with a JSON body

- If 200: results are in the response body directly

- If 202: server returns a `searchResultsDbId`; poll
  `GET /search/{entity}/{searchResultsDbId}` until results are ready

## Usage

``` r
brapi_post_search(
  con,
  endpoint,
  body = list(),
  poll_interval = 2,
  max_polls = 30L
)
```

## Arguments

- con:

  A `brapi_con` object.

- endpoint:

  Character. The search endpoint (e.g. "/search/germplasm").

- body:

  Named list. The search request body.

- poll_interval:

  Numeric. Seconds between polling attempts. Default 2.

- max_polls:

  Integer. Maximum polling attempts before giving up. Default 30.

## Value

A tibble of search results.
