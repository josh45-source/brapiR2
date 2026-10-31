## Resubmission

This is a resubmission. The Debian pretest failed one test that expected &
to be percent-encoded in a URL path; newer curl leaves it unencoded, which
is equally valid. The test now checks the decoded path instead of an exact
string.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Submission

This is a patch release. It fixes several bugs that could return incorrect
results without an error: allele matrix pagination, numeric precision in the
response cache, dosage coding of collapsed homozygotes, and null genotype cells
shifting the values after them. Because of these we are submitting within two
months of 0.2.0.

## Internet resources

brapiR2 is a client for the BrAPI web API. Examples and integration tests use
the public BrAPI test server only after `brapi_ping()` receives a successful
JSON response from it; otherwise the examples do not run and the tests are
skipped. Integration tests are also skipped on CRAN.

## Test environments

* local Windows 11, R 4.6.1
* win-builder: R-devel (2026-10-30 r90805) and R 4.6.2
* GitHub Actions: macOS (R release), Windows (R release), Ubuntu (R-devel,
  release, oldrel-1 and 4.1)

## Reverse dependencies

There are no reverse dependencies.