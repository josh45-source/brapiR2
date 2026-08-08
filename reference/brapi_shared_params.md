# Internal: Shared Parameter Documentation

Not a real function - no object is assigned here at all, only a
documentation topic. Other topics use
`@inheritParams brapi_shared_params` to pull in this description instead
of repeating it in every file. Deliberately limited to `con`:
[brapi_shared_ids](https://josh45-source.github.io/brapiR2/reference/brapi_shared_ids.md)
and
[brapi_shared_filters](https://josh45-source.github.io/brapiR2/reference/brapi_shared_filters.md)
cover the (mutually exclusive, per parameter name) ID and filter
argument families, and are always inherited alongside this one rather
than merged into it, so that a function combining `con` with either
family never has two conflicting descriptions to choose between for the
same parameter name.

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- ...:

  Additional query parameters.
