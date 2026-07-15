# Design History and Architecture

This note documents why `brapiR2` has its current structure. It is written
for rOpenSci review and future maintenance.

## Design History

`brapiR2` was built to fill a gap in the R ecosystem for the Breeding API
(BrAPI) v2 specification. The existing R client, `QBMS`, is stateful and
menu-driven: it holds a "current" program, trial, or study internally and
walks the user through an interactive selection flow. That design fits
exploratory, console-driven use, but it does not fit scripted pipelines,
parallel batch jobs, or reproducible analysis code, where the caller wants to
pass an explicit connection and get a tibble back nothing hidden, nothing
stateful.

`brapiR2` was developed with Claude Code assistance. The author directed the
architecture, the public API design, and the domain logic (which BrAPI
modules to cover, how pagination and async search should behave, how
genotype calls should be encoded as dosages); the assistant implemented
those decisions and iterated against the live public BrAPI test server
(`https://test-server.brapi.org`) to validate real request/response shapes
rather than only against synthetic fixtures. The git history for this
repository is comparatively compressed relative to the amount of surface
area covered, which reflects that AI-assisted development pattern: whole
modules were scaffolded and corrected against live server output in single
passes rather than built up commit-by-commit over weeks.

Before rOpenSci submission, the package went through a review-driven
cleanup pass: every exported function gained a runnable example (verified
against the live test server), `\dontrun{}` was replaced package-wide with
`\donttest{}` since the examples are not broken, only network-dependent,
goodpractice/lintr issues were fixed (function length, line length,
duplicated parameter docs via `@inheritParams`, assignment style), and test
coverage was raised from roughly 65% to 98% by adding mocked unit tests
alongside the existing live-server integration tests.

## Architecture Overview

`brapiR2` is organized in layers, from the caller's perspective inward:

1. **Connection and auth** - build and hold connection state explicitly
   (`brapi_connection()`, `brapi_login()`, `brapi_login_oauth2()`,
   `brapi_set_token()`). Nothing is stored globally.
2. **Request engine** - a small set of internal functions that every
   exported endpoint function is built on top of. This layer owns HTTP
   request construction, transparent pagination, the BrAPI async-search
   poll protocol, and response-to-tibble parsing.
3. **Four BrAPI modules** - Core, Germplasm, Phenotyping, and Genotyping.
   Each module is a thin, one-function-per-endpoint wrapper around the
   request engine, matching the four modules defined by the BrAPI v2
   specification itself.
4. **Convenience functions** - a small number of higher-level functions
   (`brapi_study_data()`, `brapi_get_dosage_matrix()`,
   `brapi_get_marker_map()`) that compose module functions into
   analysis-ready shapes (a wide phenotyping tibble, a numeric dosage
   matrix) without introducing any new HTTP behavior of their own.
5. **Caching and parallel fetching** - an optional, opt-in disk cache
   (`brapi_cache_enable()`, `brapi_cache_clear()`) and a parallel batch
   fetch helper (`brapi_fetch_parallel()`) layered on top of the request
   engine, both off by default.

## Component Map

| Component | Files | Responsibility |
| --- | --- | --- |
| Connection & validation | `R/connection.R` | `brapi_connection()`, `print.brapi_con()`, `is_brapi_con()`, `validate_con()` — build, print, and validate the stateless connection object every other function takes as its first argument |
| Authentication | `R/auth.R` | `brapi_login()`, `brapi_login_oauth2()`, `brapi_set_token()` - populate the connection's Bearer token via password grant, OAuth2 client-credentials grant, or direct assignment |
| Request engine | `R/request.R` | `brapi_req()`, `brapi_get()`, `brapi_get_pages()`, `brapi_cache_path()`, `brapi_cache_read()`, `brapi_post_search()`, `brapi_poll_search()`, `parse_brapi_result()` - shared HTTP plumbing: headers/auth/retry, GET pagination, cache key/lookup, the POST-search 200/202-poll protocol, and list-to-tibble parsing |
| Core module | `R/core.R` | Programs, trials, studies, locations, seasons, lists, people, server info |
| Germplasm module | `R/germplasm.R` | Germplasm records, pedigree, progeny, attributes, crosses, crossing projects, seed lots, germplasm search |
| Phenotyping module | `R/phenotyping.R` | Observation units, observations, observation variables, traits, scales, methods, images, events, phenotyping search, and `brapi_study_data()` (wide-format pivot) |
| Genotyping module | `R/genotyping.R` | Samples, variants, variant sets, calls, call sets, references, reference sets, the allele matrix, genotyping search, and the `brapi_get_dosage_matrix()` / `brapi_get_marker_map()` convenience functions |
| Caching | `R/cache.R` | `brapi_cache_enable()`, `brapi_cache_clear()` - opt-in disk cache configuration and invalidation, keyed via `rlang::hash()` |
| Parallel fetching | `R/cache.R` | `brapi_fetch_parallel()` - `furrr`/`future`-based batch fetching across many IDs |
| Utilities | `R/utils.R` | `brapi_ping()`, `brapi_endpoints()` - connectivity check and supported-endpoint introspection |
| Package doc | `R/brapiR2-package.R` | Package-level roxygen imports and the shared `@inheritParams` documentation template |

## Main Design Decisions

### Stateless connection objects, not global state

`QBMS` and similar BrAPI clients keep a mutable "current server" in package
state. `brapiR2` instead passes an explicit `brapi_con` object as the first
argument to every function, the way `httr2`, `DBI`, and most tidyverse-style
clients do. This makes it safe to hold multiple connections (e.g. two
breeding programs, or a cached and an uncached connection to the same
server) in the same session, and it makes functions easy to test in
isolation and safe to run in parallel workers.

### Tibbles everywhere, not raw lists

Every exported function that returns data returns a tibble, never a raw
parsed JSON list. BrAPI responses are deeply nested and inconsistently
shaped across servers; `parse_brapi_result()` centralizes the
list-of-records-to-tibble conversion (including the list-column fallback
for genuinely nested fields) so callers can pipe directly into `dplyr`/
`tidyr` without ever touching `$result$data` themselves.

### One function per BrAPI endpoint

Rather than one generic `brapi_call(entity, ...)` dispatcher, each BrAPI
endpoint gets its own named function (`brapi_programs()`, `brapi_trials()`,
`brapi_germplasm()`, ...). This costs more exported functions, but each one
is individually documented, individually testable, and discoverable via
autocomplete which matters more for a spec with dozens of endpoints than
a small parameter saving would.

### Transparent pagination

BrAPI list endpoints are always paginated server-side. `brapi_get()` /
`brapi_get_pages()` walk every page automatically and return the fully
concatenated result, so callers never have to reason about `page` or
`pageSize` unless they want to override the default page size.

### Async search handled internally

BrAPI's `/search/*` endpoints can respond either immediately (200, with
data) or asynchronously (202, with a `searchResultsDbId` to poll). Both
paths are collapsed into a single synchronous return value by
`brapi_post_search()` / `brapi_poll_search()`, so `brapi_search_germplasm()`
and friends behave identically to the immediate-result endpoints from the
caller's point of view.

### `httr2`, not `httr`

`httr2` is the actively developed successor to `httr`, with a pipeable
request-builder API, built-in retry/backoff, and clearer error objects. All
of `brapiR2`'s request-engine internals (mockable in tests via
`local_mocked_bindings()`) are built on `httr2`.

### Genotyping module as the key differentiator

Core, Germplasm, and Phenotyping coverage exist in other BrAPI clients.
Full genotyping support - the allele matrix's non-standard 2D pagination,
and the `brapi_get_dosage_matrix()` / `brapi_get_marker_map()` conversion
into genomic-selection-ready numeric matrices does not, and is the main
reason `brapiR2` exists as a separate package rather than a QBMS
contribution.

### Disk-based caching keyed with `rlang::hash()`

Caching is opt-in (`brapi_cache_enable()`), not automatic, so default
behavior always reflects the live server. When enabled, each cache entry is
keyed by a hash of the fully-qualified URL plus sorted, page-excluded query
parameters, so identical requests (including identical filter arguments in
a different order) reliably hit the cache and different requests never
collide.

### Mocked tests alongside integration tests

The test suite pairs two layers: `tests/testthat/test-*-mocked.R` files
patch `httr2`'s `req_perform()`/`resp_body_json()`/`resp_status()` (and
`future`/`furrr` for parallel fetching) via `local_mocked_bindings()` so
every code path — including pagination edge cases, async-search polling,
and cache hit/miss/expiry - runs deterministically without the live
server; `test-integration.R` and `test-cache-integration.R` separately
exercise the real test server and are skipped on CRAN and when offline.
Together they bring line coverage to about 98%.

## Boundaries

The current design deliberately leaves several things out of scope:

- **Read-only.** `brapiR2` retrieves BrAPI data; it does not implement the
  BrAPI `POST`/`PUT` endpoints for writing germplasm, observations, or
  other records back to a server.
- **No analysis.** Dosage matrices and wide phenotyping tibbles are
  produced in shapes that downstream genomic-selection and analysis
  packages expect, but `brapiR2` does not itself fit models, compute BLUPs,
  or perform GWAS.
- **No server-specific workarounds.** `brapiR2` targets the BrAPI v2
  specification as written. It does not carry bespoke branches for
  particular server implementations (BMS, BreedBase, EBS, GIGWA,
  Germinate); servers that deviate from spec are expected to be fixed
  upstream rather than special-cased here.
- **No visualization.** Plotting genotype, pedigree, or phenotype data is
  left to downstream packages that consume `brapiR2`'s tibbles.

## Relationship to Other Tools

`brapiR2` is designed to sit at the start of a breeding-data analysis
pipeline, not to replace the tools downstream of it:

- **phenoQC** - phenotypic data cleaning and quality control, consuming
  the tibbles from `brapi_observations()` / `brapi_study_data()`.
- **vcf2dosage** - genotype format conversion, complementary to
  `brapi_get_dosage_matrix()` for data that originates as VCF rather than
  from a BrAPI server.
- **ggvariant** - variant and genotype visualization, consuming
  `brapi_variants()` / `brapi_allele_matrix()` output.
- **gsbench** - genomic selection model benchmarking, consuming the
  dosage matrix and phenotyping tibble directly as model inputs.

In each case, `brapiR2`'s job ends at "a tidy tibble or matrix retrieved
from a BrAPI server"; cleaning, visualization, and modeling are left to
packages built for those tasks specifically.

## Maintenance Considerations

The most likely sources of future maintenance work, roughly in order of
likelihood:

- **BrAPI specification updates.** BrAPI v2 is still evolving; new
  optional fields, endpoints, or search parameters should mostly be
  additive and land as new module functions or new `...` pass-through
  arguments, not breaking changes to existing signatures.
- **Server response drift.** Real BrAPI servers do not always implement
  the spec identically (see `brapi_study_data()`'s client-side filter
  fallback, and `brapi_get_marker_map()`'s `variantName`/`variantNames`
  handling). New drift should be handled the same way: defensively, in the
  module or convenience function affected, without changing the request
  engine.
- **`httr2` changes.** The request engine (`R/request.R`) is the sole
  integration point with `httr2`; API changes there should only ever
  require edits in that one file.
- **Test server availability.** `\donttest{}` examples and the
  integration test suite depend on `https://test-server.brapi.org` staying
  reachable and populated with its current dummy dataset (`program1`,
  `study1`, `variantset1`, and similar fixture IDs referenced throughout
  the examples and tests). If that server's dataset changes shape, the
  mocked test suite still protects the request-engine logic, but examples
  and integration tests would need their hardcoded IDs updated.
