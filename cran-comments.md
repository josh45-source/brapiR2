## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

* The NOTE reports that the Title field is not in title case, suggesting
  'BrAPI' V2 in place of 'BrAPI' v2. The BrAPI specification
  (<https://brapi.org>) writes its own version designation in lower case,
  so capitalising it would misname the standard. The Title is left as is.

* The NOTE also lists possibly misspelled words in DESCRIPTION: BrAPI,
  Germplasm, Phenotyping, Tidyverse, async, bioinformaticians,
  specification's and tibbles. These are correct - BrAPI is the name of
  the specification, Germplasm and Phenotyping are its module names, and
  the rest are standard terms in R and plant breeding.

## Internet resources

brapiR2 is a client for the BrAPI web API, so its examples and integration
tests need a live server. Examples call `brapi_ping()` first and run only if
the public test server responds, reporting the server as unreachable rather
than failing. Integration tests are guarded with `skip_on_cran()` and a
connectivity check.

## Test environments

* local Windows 11, R 4.6.1
* win-builder: R-devel and R-release
* GitHub Actions: Windows Server 2022 (R release), Ubuntu 24.04
  (R 4.5.3, release, devel), macOS (R release)
