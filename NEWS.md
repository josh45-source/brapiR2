# brapiR2 (development version)

## brapiR2 0.1.0

### New features

* Initial release with full BrAPI v2.1 endpoint coverage.
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
