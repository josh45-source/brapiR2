# Internal: Shared Filter Parameter Documentation

Not a real function - like
[brapi_shared_params](https://josh45-source.github.io/brapiR2/reference/brapi_shared_params.md),
this exists only as an `@inheritParams brapi_shared_filters` target for
the *optional* filter arguments (default `NULL`) that several
list-endpoints share, as opposed to the required identifiers documented
in
[brapi_shared_ids](https://josh45-source.github.io/brapiR2/reference/brapi_shared_ids.md).

## Arguments

- studyDbId:

  Character or NULL. Filter by study.

- variantSetDbId:

  Character or NULL. Filter by variant set.

- programDbId:

  Character or NULL. Filter by program.

- trialDbId:

  Character or NULL. Filter by trial.
