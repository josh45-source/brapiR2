# Internal: Shared Search-Body Parameter Documentation

Not a real function - like
[brapi_shared_params](https://josh45-source.github.io/brapiR2/reference/brapi_shared_params.md),
this exists only as an `@inheritParams brapi_shared_search` target for
the `brapi_search_*()` functions, which build a POST search body rather
than a GET query string. Bundles `con` together with that `...`, rather
than requiring a second `@inheritParams brapi_shared_params`, since the
two topics define `...` differently and inheriting both would leave it
ambiguous which description wins.

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional search body parameters.
