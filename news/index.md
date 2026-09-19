# Changelog

## brapiR2 (development version)

#### Breaking changes

- [`brapi_get_marker_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_get_marker_map.md)
  no longer reads position data from
  [`brapi_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_variants.md)
  (`referenceName`/`start`, which many servers - including the public
  test server - leave `NA`, since the BrAPI spec makes those fields
  optional on `Variant`). It now queries the Genome Maps entity’s
  `/markerpositions` endpoint instead, which places a marker on a named
  map (genetic or physical) rather than a variant on a reference
  assembly. **Signature change**:
  `brapi_get_marker_map(con, variantSetDbId = NULL, mapDbId = NULL)`,
  requiring exactly one of the two identifiers. The returned tibble’s
  columns have changed to `variantDbId`, `variantName`, `mapDbId`,
  `mapName`, `type`, `unit`, `linkageGroupName`, `position` -
  `referenceName`/`start` are gone. Existing positional calls
  (`brapi_get_marker_map(con, variantSetDbId)`) still work, but code
  reading `referenceName` or `start` from the result will break.
- [`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)
  and
  [`brapi_germplasm_progeny()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_progeny.md)
  now query `/pedigree?germplasmDbId=` instead of the
  `/germplasm/{germplasmDbId}/pedigree` and
  `/germplasm/{germplasmDbId}/progeny` sub-resources, which BrAPI
  deprecated in v2.1. **The returned columns have changed**: 15 rather
  than 8, `pedigree` is now `pedigreeString`, and `parents`, `siblings`
  and `progeny` are list-columns of tidy tibbles rather than raw nested
  lists. The added fields are `progeny`, `germplasmPUI`,
  `defaultDisplayName`, `breedingMethodName`, `breedingMethodDbId`,
  `additionalInfo` and `externalReferences`
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).

#### Bug fixes

- [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
  no longer silently returns the wrong study’s observations on servers
  that don’t implement the `studyDbId` filter on `/observations`
  server-side (which triggers a client-side fallback that fetches all
  observations and filters locally). The filter used
  `dplyr::filter(.data$studyDbId == studyDbId)`, which - because the
  function’s own argument is also named `studyDbId` - resolved the
  right-hand side to the data column itself, making the comparison
  always `TRUE` and returning every study’s observations rather than
  just the requested one. Fixed to `.data$studyDbId == .env$studyDbId`,
  which correctly disambiguates the data column from the function
  argument.
- [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
  no longer errors on studies where a trait is measured on only some
  observation units.
  [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html)
  fills the absent combinations with zero-length elements, and the
  simplification step’s [`unlist()`](https://rdrr.io/r/base/unlist.html)
  silently dropped them, returning a column shorter than the table and
  failing inside
  [`dplyr::across()`](https://dplyr.tidyverse.org/reference/across.html).
  Unmeasured cells are now `NA`, and simplified columns are character
  throughout, which is how BrAPI returns observation values
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- Records that differ only in JSON object key order are no longer
  treated as distinct. Key order is not significant in JSON, and at
  least one server varies it between records in the same response;
  nested objects are now normalised as they are parsed. On the study
  used to reproduce this, 75 of 4,613 observations were affected, and
  [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
  additionally drops exact duplicate records before pivoting, reporting
  how many it removed ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- [`brapi_login()`](https://josh45-source.github.io/brapiR2/reference/brapi_login.md)
  now builds its request the same way every other function does. It
  previously hardcoded `/brapi/`, so authentication was impossible on
  servers using a different path, and it sent neither the user agent nor
  the `Accept` header.
- `con$timeout` is now applied to requests. The argument has been
  accepted and documented since 0.1.0 but never took effect, leaving
  every request on curl’s own default.
- Observation values are trimmed of surrounding whitespace before being
  returned by
  [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md),
  so values such as `"80 "` do not become `NA` on conversion to numeric.
  Reported by [@dwaring87](https://github.com/dwaring87) from a
  development server; not reproducible across 21 studies on T3/Oat
  Sandbox, T3/Wheat Sandbox and Cassavabase, so the trim is defensive
  (ropensci/software-review#792).
- [`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)
  and
  [`brapi_germplasm_progeny()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_progeny.md)
  filter the response on `germplasmDbId` client-side. The public test
  server ignores that parameter on `/pedigree`, so a request for one
  germplasm returned another alongside it
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- A single-object response whose `result` carries a field named `data`
  is no longer mistaken for a collection. The parser treated any
  `result$data` as the record envelope, so `/lists/{listDbId}` returned
  only its members and discarded every other field. `data` is now
  treated as the envelope only when it is absent of scalars — that is,
  empty or holding objects.
- A collection whose records are bare strings is no longer mistaken for
  a single object. `/commoncropnames` returns its crop names that way,
  and the whole response came back as one row with a list-column.

#### Minor improvements

- Failed requests now report what the server said, not just the HTTP
  status. A 401 from a Breedbase server reads “You must login and have
  permission to access this BrAPI call” rather than a bare
  `HTTP 401 Unauthorized`, and a failed login reports the server’s
  reason — “Incorrect Password”, or “JSON array body required” — instead
  of “no access token returned”. Servers report errors in several
  different ways, and all of the forms seen across the test server,
  Breedbase, T3 and GRIN-Global are handled; an HTML error page is not
  shown, since it is never useful to a user
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
  checks that the observations it received are really from the study
  asked for. A server may accept the `studyDbId` filter and ignore it —
  the public test server does exactly this on `/pedigree` — in which
  case every study’s observations would have been pivoted together.
  Extra studies are now filtered out, and the function says how many it
  found ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).

#### New features

- New Genome Maps entity support (`R/genome_maps.R`):
  [`brapi_maps()`](https://josh45-source.github.io/brapiR2/reference/brapi_maps.md),
  [`brapi_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_map.md),
  [`brapi_map_linkage_groups()`](https://josh45-source.github.io/brapiR2/reference/brapi_map_linkage_groups.md),
  [`brapi_marker_positions()`](https://josh45-source.github.io/brapiR2/reference/brapi_marker_positions.md),
  [`brapi_search_marker_positions()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_marker_positions.md).
- New Pedigree entity support (`R/germplasm.R`):
  [`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md)
  and
  [`brapi_search_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_pedigree.md)
  retrieve pedigree records across many germplasm in one call, via
  `/pedigree` and `/search/pedigree`.
  [`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)
  and
  [`brapi_germplasm_progeny()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_progeny.md)
  now delegate to
  [`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md)
  rather than calling the sub-resources BrAPI deprecated in v2.1. Each
  row is one pedigree node; `parents`, `siblings` and `progeny`, when
  requested, are list-columns of tidy per-node tibbles rather than raw
  nested lists, so a node with several relatives is never silently
  collapsed to one row.
- New Ontologies entity support (`R/phenotyping.R`):
  [`brapi_ontologies()`](https://josh45-source.github.io/brapiR2/reference/brapi_ontologies.md)
  and
  [`brapi_ontology()`](https://josh45-source.github.io/brapiR2/reference/brapi_ontology.md),
  cross-referenced from
  [`brapi_traits()`](https://josh45-source.github.io/brapiR2/reference/brapi_traits.md),
  [`brapi_scales()`](https://josh45-source.github.io/brapiR2/reference/brapi_scales.md),
  [`brapi_methods()`](https://josh45-source.github.io/brapiR2/reference/brapi_methods.md),
  and
  [`brapi_observation_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_variables.md).
- brapiR2 now wraps 32 of the 37 BrAPI v2.1 entities across all four
  modules (49 of 138 retrieval endpoints); see `DESIGN.md` for the full
  coverage breakdown and which entities remain uncovered.
- [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  gains a `path` argument for servers that do not serve BrAPI under
  `/brapi/`. GRIN-Global instances use `gringlobal/brapi` and were
  previously unreachable; Germinate and GIGWA deployments commonly sit
  under their own prefixes too. Defaults to `"brapi"`, so existing code
  is unaffected. [`print()`](https://rdrr.io/r/base/print.html) shows
  the path only when it differs from the default, and the cache key now
  includes it, so two servers sharing a hostname no longer collide.
- Requests now send a user agent identifying brapiR2, its version, and
  the httr2 and R versions in use, so server operators can see what is
  calling them. Requests made on continuous integration are marked as
  such.
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  gains a `user_agent` argument to override it
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- New
  [`brapi_location()`](https://josh45-source.github.io/brapiR2/reference/brapi_location.md)
  retrieves a single location by ID, so a user who knows a study’s
  `locationDbId` can fetch its coordinates without listing every
  location and filtering. Verified against the public test server,
  Cassavabase, T3/Oat Sandbox and USDA-GRIN
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- New
  [`brapi_list()`](https://josh45-source.github.io/brapiR2/reference/brapi_list.md)
  retrieves a single list by ID together with its contents.
  [`brapi_lists()`](https://josh45-source.github.io/brapiR2/reference/brapi_lists.md)
  returns only metadata, so there was previously no way to reach a
  list’s members at all. The members come back as a character vector in
  the `data` list-column, ready to pass to another function
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- [`brapi_get()`](https://josh45-source.github.io/brapiR2/reference/brapi_get.md)
  and
  [`brapi_post_search()`](https://josh45-source.github.io/brapiR2/reference/brapi_post_search.md)
  are now exported, so an endpoint brapiR2 does not wrap, a server
  extension, or a query parameter no named function exposes can be
  reached without dropping to raw HTTP. Pagination, caching,
  authentication and error reporting work as they do for the named
  functions. Recommended by both reviewers and by the rOpenSci packaging
  guidelines ([@dwaring87](https://github.com/dwaring87),
  [@jmh579](https://github.com/jmh579), ropensci/software-review#792).

#### Deprecated

- [`brapi_fetch_parallel()`](https://josh45-source.github.io/brapiR2/reference/brapi_fetch_parallel.md)
  no longer sets or restores a `future` plan itself. Per the future
  package’s best-practices vignette, the parallel backend is now the
  caller’s choice: call
  [`future::plan()`](https://future.futureverse.org/reference/plan.html)
  before calling
  [`brapi_fetch_parallel()`](https://josh45-source.github.io/brapiR2/reference/brapi_fetch_parallel.md)
  to fetch in parallel. The `.workers` argument is deprecated -
  supplying it now emits a warning and has no effect.

#### Documentation

- Added `LICENSE.md` with the full MIT licence text, which was missing
  from the repository, so GitHub had no licence to detect and anyone
  opening `LICENSE` found no grant of rights. The copyright holder is
  now named explicitly rather than “brapiR2 authors”
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- @dwaring87 and [@jmh579](https://github.com/jmh579) are recorded in
  `DESCRIPTION` with the `rev` role for their rOpenSci reviews
  (ropensci/software-review#792).
- Corrected a misspelling in the QBMS comparison table in the
  getting-started vignette ([@jmh579](https://github.com/jmh579),
  ropensci/software-review#792).
- The getting-started vignette’s “Caching and Parallel Fetching” section
  now explains what each feature does and when to reach for it, rather
  than describing the `future` package at length. The design rationale
  for why
  [`brapi_fetch_parallel()`](https://josh45-source.github.io/brapiR2/reference/brapi_fetch_parallel.md)
  does not set a plan has moved to `DESIGN.md`
  ([@jmh579](https://github.com/jmh579), ropensci/software-review#792).
- The “Connecting to a Server” section now links to Authentication and
  to Handling Credentials Safely, which most users need before anything
  else on the page ([@jmh579](https://github.com/jmh579),
  ropensci/software-review#792).
- The recommendation on when to choose QBMS and when to choose brapiR2
  now sits with the comparison it belongs to, rather than after the
  references ([@jmh579](https://github.com/jmh579),
  ropensci/software-review#792).
- The vignette’s parallel-fetching chunks are guarded on `furrr` and
  `future` being installed, so the vignette builds where suggested
  packages are absent.
- `DESCRIPTION` now declares `Language: en-GB`, and the package’s prose
  has been made consistent with it. Six American spellings were
  corrected, and `inst/WORDLIST` has been extended with the domain
  vocabulary and package names the spellchecker cannot know
  ([@jmh579](https://github.com/jmh579), ropensci/software-review#792).
- The README installs with
  [`pak::pak()`](https://pak.r-lib.org/reference/pak.html) rather than
  `remotes::install_github()`, which now warns
  ([@jmh579](https://github.com/jmh579), ropensci/software-review#792),
  and notes that `remotes` and `devtools` need `build_vignettes = TRUE`
  for the vignette to be installed at all
  ([@dwaring87](https://github.com/dwaring87),
  ropensci/software-review#792).
- The README leads with what brapiR2 does and which BrAPI modules it
  covers. The QBMS comparison table and the notes on other BrAPI clients
  have moved into Related Packages, and Authentication now comes before
  the extended examples ([@jmh579](https://github.com/jmh579),
  ropensci/software-review#792).
- The genomic selection article no longer fits the same trait with BGLR
  and sommer as well as rrBLUP. The comparison of when to reach for each
  package stays; the code that fitted them is shown rather than run,
  since neither result was used and both added a heavy dependency to the
  build ([@jmh579](https://github.com/jmh579),
  ropensci/software-review#792).
- Every wrapper’s help page now has a “BrAPI endpoint” section naming
  the endpoint it calls, linking to that endpoint’s definition in the
  v2.1 specification, and listing the query parameters the specification
  defines for it.
  [`brapi_studies()`](https://josh45-source.github.io/brapiR2/reference/brapi_studies.md)
  documented only `trialDbId` while the specification defines nine; the
  same gap existed across the package
  ([@dwaring87](https://github.com/dwaring87),
  [@jmh579](https://github.com/jmh579), ropensci/software-review#792).
- The coverage figures are now derived from the specification rather
  than stated from memory. `dev/brapi-spec.R` reads the pinned `V2.1`
  tag of the BrAPI specification repository and writes the endpoint
  inventory that the documentation is generated from. Correcting against
  it: the specification defines 37 top-level entities rather than 36,
  brapiR2 wraps 49 retrieval endpoints rather than 56, and Planned
  Crosses was missing from the list of uncovered entities.
- New
  [`?brapi_coverage`](https://josh45-source.github.io/brapiR2/reference/brapi_coverage.md)
  lists every BrAPI endpoint brapiR2 wraps, grouped by module, with the
  function that wraps each one, and names the entities that have no
  wrapper. Asked for by [@jmh579](https://github.com/jmh579) and
  [@dwaring87](https://github.com/dwaring87)
  (ropensci/software-review#792).
- `DESCRIPTION` no longer names specific BrAPI implementations. It
  claimed compatibility with Breedbase, BMS, EBS, GIGWA and Germinate,
  of which only Breedbase had been tested; it now claims the
  specification instead. The README records which servers brapiR2 has
  actually been exercised against — eight, across three implementations
  — and which it has not ([@jmh579](https://github.com/jmh579),
  ropensci/software-review#792).

#### Testing

- Substantially expanded the mocked and live-server test suites
  alongside the features above: argument-capturing tests for every new
  thin wrapper, dedicated tests for the pedigree relative-list parsing
  (nodes with parents, with progeny, and with neither), and guarded
  integration tests against the public BrAPI test server for every new
  function.
- Added tests for the work done in response to review: URL construction
  and cache keys under a non-default `path`, the user agent as sent and
  as overridden, login reaching a non-standard path, JSON key-order
  normalisation, unmeasured traits filling with `NA` rather than
  shortening the column, whitespace trimming, the client-side
  `studyDbId` and `germplasmDbId` filters, the three response shapes the
  parser must tell apart, and the error-message extraction for each form
  a server uses.

### brapiR2 0.1.0

#### New features

- Initial release covering the BrAPI v2.1 specification’s Core,
  Germplasm, Phenotyping, and Genotyping modules.
- **Core module**:
  [`brapi_programs()`](https://josh45-source.github.io/brapiR2/reference/brapi_programs.md),
  [`brapi_trials()`](https://josh45-source.github.io/brapiR2/reference/brapi_trials.md),
  [`brapi_studies()`](https://josh45-source.github.io/brapiR2/reference/brapi_studies.md),
  [`brapi_locations()`](https://josh45-source.github.io/brapiR2/reference/brapi_locations.md),
  [`brapi_seasons()`](https://josh45-source.github.io/brapiR2/reference/brapi_seasons.md),
  [`brapi_lists()`](https://josh45-source.github.io/brapiR2/reference/brapi_lists.md),
  [`brapi_people()`](https://josh45-source.github.io/brapiR2/reference/brapi_people.md),
  [`brapi_server_info()`](https://josh45-source.github.io/brapiR2/reference/brapi_server_info.md).
- **Germplasm module**:
  [`brapi_germplasm()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm.md),
  [`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md),
  [`brapi_germplasm_progeny()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_progeny.md),
  [`brapi_crosses()`](https://josh45-source.github.io/brapiR2/reference/brapi_crosses.md),
  [`brapi_crossing_projects()`](https://josh45-source.github.io/brapiR2/reference/brapi_crossing_projects.md),
  [`brapi_seed_lots()`](https://josh45-source.github.io/brapiR2/reference/brapi_seed_lots.md),
  [`brapi_search_germplasm()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_germplasm.md).
- **Phenotyping module**:
  [`brapi_observation_units()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_units.md),
  [`brapi_observations()`](https://josh45-source.github.io/brapiR2/reference/brapi_observations.md),
  [`brapi_observation_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_variables.md),
  [`brapi_traits()`](https://josh45-source.github.io/brapiR2/reference/brapi_traits.md),
  [`brapi_scales()`](https://josh45-source.github.io/brapiR2/reference/brapi_scales.md),
  [`brapi_methods()`](https://josh45-source.github.io/brapiR2/reference/brapi_methods.md),
  [`brapi_images()`](https://josh45-source.github.io/brapiR2/reference/brapi_images.md),
  [`brapi_events()`](https://josh45-source.github.io/brapiR2/reference/brapi_events.md),
  [`brapi_search_observations()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_observations.md),
  [`brapi_search_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_variables.md).
- **Genotyping module**:
  [`brapi_samples()`](https://josh45-source.github.io/brapiR2/reference/brapi_samples.md),
  [`brapi_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_variants.md),
  [`brapi_variant_sets()`](https://josh45-source.github.io/brapiR2/reference/brapi_variant_sets.md),
  [`brapi_calls()`](https://josh45-source.github.io/brapiR2/reference/brapi_calls.md),
  [`brapi_call_sets()`](https://josh45-source.github.io/brapiR2/reference/brapi_call_sets.md),
  [`brapi_references()`](https://josh45-source.github.io/brapiR2/reference/brapi_references.md),
  [`brapi_reference_sets()`](https://josh45-source.github.io/brapiR2/reference/brapi_reference_sets.md),
  [`brapi_allele_matrix()`](https://josh45-source.github.io/brapiR2/reference/brapi_allele_matrix.md),
  [`brapi_search_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_variants.md),
  [`brapi_search_calls()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_calls.md).
- Convenience functions:
  [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
  (wide-format phenotype table),
  [`brapi_get_dosage_matrix()`](https://josh45-source.github.io/brapiR2/reference/brapi_get_dosage_matrix.md),
  [`brapi_get_marker_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_get_marker_map.md).
- Stateless
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  — no global state or side effects.
- Automatic pagination for all GET endpoints.
- Async search handling (202 status + polling).
- Built-in response caching with
  [`brapi_cache_enable()`](https://josh45-source.github.io/brapiR2/reference/brapi_cache_enable.md).
- Parallel batch fetching with
  [`brapi_fetch_parallel()`](https://josh45-source.github.io/brapiR2/reference/brapi_fetch_parallel.md).
