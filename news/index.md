# Changelog

## brapiR2 (development version)

### brapiR2 0.1.0

#### New features

- Initial release with full BrAPI v2.1 endpoint coverage.
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
