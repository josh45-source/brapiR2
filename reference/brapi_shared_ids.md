# Internal: Shared Identifier Parameter Documentation

Not a real function - like
[brapi_shared_params](https://josh45-source.github.io/brapiR2/reference/brapi_shared_params.md),
this exists only as an `@inheritParams brapi_shared_ids` target, for the
*required* single-item identifier arguments ("get this one thing by ID")
that several endpoints share. Compare
[brapi_shared_filters](https://josh45-source.github.io/brapiR2/reference/brapi_shared_filters.md),
the equivalent for optional (default `NULL`) filter arguments of the
same names.

## Arguments

- studyDbId:

  Character. The unique study identifier.

- germplasmDbId:

  Character. The unique germplasm identifier.

- trialDbId:

  Character. The unique trial identifier.

- programDbId:

  Character. The unique program identifier.
