# Contributing to brapiR2

Thank you for your interest in contributing to brapiR2!

## How to Contribute

1. **Fork** the repository on GitHub
2. **Clone** your fork locally
3. Create a **branch** for your feature or fix
4. Make your changes following the style guide below
5. **Test** your changes with `devtools::check()`
6. Submit a **pull request**

## Style Guide

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use `roxygen2` for documentation
- All exported functions must have `@examples`
- Use `cli` for user-facing messages (not `message()` or `cat()`)

## Adding a New BrAPI Endpoint

1. Add the function in the appropriate module file (`R/core.R`, `R/germplasm.R`, etc.)
2. Follow the existing pattern: `con` as first argument, `...` for query params
3. Use `brapi_get()` or `brapi_post_search()` internally
4. Add `#' @export` to the function's roxygen block and run `devtools::document()`
   to regenerate `NAMESPACE` (it carries a roxygen2 "do not edit by hand" header,
   so never edit it directly)
5. Write tests in `tests/testthat/`
6. Update `NEWS.md`

## Running the Test Suite

- Integration tests run against the public BrAPI test server at
  <https://test-server.brapi.org> and require no authentication token.
- These tests are guarded by `skip_on_cran()` and `skip_if_offline()`, so they
  are skipped automatically when there's no network access.
- Mocked tests use `testthat::local_mocked_bindings()` and run fully offline.
- The parallel batch-fetching tests need `furrr` and `future` installed.
  They are skipped rather than failed when either package is missing.

## Reporting Issues

- Use the GitHub issue tracker
- Include a minimal reproducible example
- Note which BrAPI server you're connecting to (if relevant)

## Code of Conduct

Please note that this package is released with a
[Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By
contributing to this project, you agree to abide by its terms.
