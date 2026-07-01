# Contributing to brapiR2

Thank you for your interest in contributing to brapiR2!

## How to Contribute

1.  **Fork** the repository on GitHub
2.  **Clone** your fork locally
3.  Create a **branch** for your feature or fix
4.  Make your changes following the style guide below
5.  **Test** your changes with `devtools::check()`
6.  Submit a **pull request**

## Style Guide

- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use `roxygen2` for documentation
- All exported functions must have `@examples`
- Use `cli` for user-facing messages (not
  [`message()`](https://rdrr.io/r/base/message.html) or
  [`cat()`](https://rdrr.io/r/base/cat.html))

## Adding a New BrAPI Endpoint

1.  Add the function in the appropriate module file (`R/core.R`,
    `R/germplasm.R`, etc.)
2.  Follow the existing pattern: `con` as first argument, `...` for
    query params
3.  Use
    [`brapi_get()`](https://josh45-source.github.io/brapiR2/reference/brapi_get.md)
    or
    [`brapi_post_search()`](https://josh45-source.github.io/brapiR2/reference/brapi_post_search.md)
    internally
4.  Add the function to `NAMESPACE` exports
5.  Write tests in `tests/testthat/`
6.  Update `NEWS.md`

## Reporting Issues

- Use the GitHub issue tracker
- Include a minimal reproducible example
- Note which BrAPI server you’re connecting to (if relevant)

## Code of Conduct

Please be respectful and constructive. We follow the [Contributor
Covenant](https://www.contributor-covenant.org/) code of conduct.
