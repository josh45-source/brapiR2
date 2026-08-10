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
  retrieve pedigree records across many germplasm in one call (via
  `/pedigree` and `/search/pedigree`), complementing the existing
  single-germplasm
  [`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md).
  Each row is one pedigree node; `parents`, `siblings`, and `progeny`,
  when requested, are list-columns of tidy per-node tibbles (not raw
  nested lists), so a marker on several maps or a node with several
  relatives is never silently collapsed to one row.
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
- brapiR2 now wraps 32 of the 36 BrAPI v2.1 entities across all four
  modules (56 of 138 retrieval endpoints); see `DESIGN.md` for the full
  coverage breakdown and which entities remain uncovered.

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

#### Testing

- Substantially expanded the mocked and live-server integration test
  suites alongside the features above: argument-capturing tests for
  every new thin wrapper, dedicated tests for the pedigree relative-list
  parsing (nodes with parents, with progeny, and with neither), and
  guarded integration tests against the public BrAPI test server for
  every new function.

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
