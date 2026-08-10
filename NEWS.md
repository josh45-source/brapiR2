# brapiR2 (development version)

### Breaking changes

* `brapi_get_marker_map()` no longer reads position data from
  `brapi_variants()` (`referenceName`/`start`, which many servers -
  including the public test server - leave `NA`, since the BrAPI spec
  makes those fields optional on `Variant`). It now queries the Genome
  Maps entity's `/markerpositions` endpoint instead, which places a
  marker on a named map (genetic or physical) rather than a variant on a
  reference assembly. **Signature change**:
  `brapi_get_marker_map(con, variantSetDbId = NULL, mapDbId = NULL)`,
  requiring exactly one of the two identifiers. The returned tibble's
  columns have changed to `variantDbId`, `variantName`, `mapDbId`,
  `mapName`, `type`, `unit`, `linkageGroupName`, `position` -
  `referenceName`/`start` are gone. Existing positional calls
  (`brapi_get_marker_map(con, variantSetDbId)`) still work, but code
  reading `referenceName` or `start` from the result will break.

### Bug fixes

* `brapi_study_data()` no longer silently returns the wrong study's
  observations on servers that don't implement the `studyDbId` filter on
  `/observations` server-side (which triggers a client-side fallback that
  fetches all observations and filters locally). The filter used
  `dplyr::filter(.data$studyDbId == studyDbId)`, which - because the
  function's own argument is also named `studyDbId` - resolved the
  right-hand side to the data column itself, making the comparison always
  `TRUE` and returning every study's observations rather than just the
  requested one. Fixed to `.data$studyDbId == .env$studyDbId`, which
  correctly disambiguates the data column from the function argument.

### New features

* New Genome Maps entity support (`R/genome_maps.R`): `brapi_maps()`,
  `brapi_map()`, `brapi_map_linkage_groups()`, `brapi_marker_positions()`,
  `brapi_search_marker_positions()`.
* New Pedigree entity support (`R/germplasm.R`): `brapi_pedigree()` and
  `brapi_search_pedigree()` retrieve pedigree records across many
  germplasm in one call (via `/pedigree` and `/search/pedigree`),
  complementing the existing single-germplasm
  `brapi_germplasm_pedigree()`. Each row is one pedigree node; `parents`,
  `siblings`, and `progeny`, when requested, are list-columns of tidy
  per-node tibbles (not raw nested lists), so a marker on several maps or
  a node with several relatives is never silently collapsed to one row.
* New Ontologies entity support (`R/phenotyping.R`): `brapi_ontologies()`
  and `brapi_ontology()`, cross-referenced from `brapi_traits()`,
  `brapi_scales()`, `brapi_methods()`, and
  `brapi_observation_variables()`.
* brapiR2 now wraps 32 of the 36 BrAPI v2.1 entities across all four
  modules (56 of 138 retrieval endpoints); see `DESIGN.md` for the full
  coverage breakdown and which entities remain uncovered.

### Deprecated

* `brapi_fetch_parallel()` no longer sets or restores a `future` plan
  itself. Per the future package's best-practices vignette, the parallel
  backend is now the caller's choice: call `future::plan()` before
  calling `brapi_fetch_parallel()` to fetch in parallel. The `.workers`
  argument is deprecated - supplying it now emits a warning and has no
  effect.

### Testing

* Substantially expanded the mocked and live-server integration test
  suites alongside the features above: argument-capturing tests for
  every new thin wrapper, dedicated tests for the pedigree relative-list
  parsing (nodes with parents, with progeny, and with neither), and
  guarded integration tests against the public BrAPI test server for
  every new function.

## brapiR2 0.1.0

### New features

* Initial release covering the BrAPI v2.1 specification's Core,
  Germplasm, Phenotyping, and Genotyping modules.
* **Core module**: `brapi_programs()`, `brapi_trials()`, `brapi_studies()`,
  `brapi_locations()`, `brapi_seasons()`, `brapi_lists()`, `brapi_people()`,
  `brapi_server_info()`.
* **Germplasm module**: `brapi_germplasm()`, `brapi_germplasm_pedigree()`,
  `brapi_germplasm_progeny()`, `brapi_crosses()`, `brapi_crossing_projects()`,
  `brapi_seed_lots()`, `brapi_search_germplasm()`.
* **Phenotyping module**: `brapi_observation_units()`, `brapi_observations()`,
  `brapi_observation_variables()`, `brapi_traits()`, `brapi_scales()`,
  `brapi_methods()`, `brapi_images()`, `brapi_events()`,
  `brapi_search_observations()`, `brapi_search_variables()`.
* **Genotyping module**: `brapi_samples()`, `brapi_variants()`,
  `brapi_variant_sets()`, `brapi_calls()`, `brapi_call_sets()`,
  `brapi_references()`, `brapi_reference_sets()`, `brapi_allele_matrix()`,
  `brapi_search_variants()`, `brapi_search_calls()`.
* Convenience functions: `brapi_study_data()` (wide-format phenotype table),
  `brapi_get_dosage_matrix()`, `brapi_get_marker_map()`.
* Stateless `brapi_connection()` — no global state or side effects.
* Automatic pagination for all GET endpoints.
* Async search handling (202 status + polling).
* Built-in response caching with `brapi_cache_enable()`.
* Parallel batch fetching with `brapi_fetch_parallel()`.
