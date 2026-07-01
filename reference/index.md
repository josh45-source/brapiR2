# Package index

## Connection & Authentication

Create connections and authenticate with BrAPI servers.

- [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  : Create a BrAPI Connection Object
- [`brapi_login()`](https://josh45-source.github.io/brapiR2/reference/brapi_login.md)
  : Login to a BrAPI Server with Username and Password
- [`brapi_login_oauth2()`](https://josh45-source.github.io/brapiR2/reference/brapi_login_oauth2.md)
  : Login to a BrAPI Server with OAuth 2.0
- [`brapi_set_token()`](https://josh45-source.github.io/brapiR2/reference/brapi_set_token.md)
  : Manually Set an Authentication Token
- [`brapi_ping()`](https://josh45-source.github.io/brapiR2/reference/brapi_ping.md)
  : Ping a BrAPI Server
- [`brapi_endpoints()`](https://josh45-source.github.io/brapiR2/reference/brapi_endpoints.md)
  : List Available Endpoints
- [`print(`*`<brapi_con>`*`)`](https://josh45-source.github.io/brapiR2/reference/print.brapi_con.md)
  : Print a BrAPI Connection Object

## Core Module

Programs, trials, studies, locations, and other organizational entities.

- [`brapi_programs()`](https://josh45-source.github.io/brapiR2/reference/brapi_programs.md)
  : List Breeding Programs
- [`brapi_program()`](https://josh45-source.github.io/brapiR2/reference/brapi_program.md)
  : Get a Single Program by ID
- [`brapi_trials()`](https://josh45-source.github.io/brapiR2/reference/brapi_trials.md)
  : List Trials
- [`brapi_trial()`](https://josh45-source.github.io/brapiR2/reference/brapi_trial.md)
  : Get a Single Trial by ID
- [`brapi_studies()`](https://josh45-source.github.io/brapiR2/reference/brapi_studies.md)
  : List Studies
- [`brapi_study()`](https://josh45-source.github.io/brapiR2/reference/brapi_study.md)
  : Get a Single Study by ID
- [`brapi_locations()`](https://josh45-source.github.io/brapiR2/reference/brapi_locations.md)
  : List Locations
- [`brapi_seasons()`](https://josh45-source.github.io/brapiR2/reference/brapi_seasons.md)
  : List Seasons
- [`brapi_lists()`](https://josh45-source.github.io/brapiR2/reference/brapi_lists.md)
  : List Generic Lists
- [`brapi_people()`](https://josh45-source.github.io/brapiR2/reference/brapi_people.md)
  : List People
- [`brapi_server_info()`](https://josh45-source.github.io/brapiR2/reference/brapi_server_info.md)
  : Get Server Info

## Germplasm Module

Germplasm management, pedigrees, crosses, and seed lots.

- [`brapi_germplasm()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm.md)
  : List Germplasm
- [`brapi_germplasm_detail()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_detail.md)
  : Get a Single Germplasm by ID
- [`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)
  : Get Germplasm Pedigree
- [`brapi_germplasm_progeny()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_progeny.md)
  : Get Germplasm Progeny
- [`brapi_germplasm_attributes()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_attributes.md)
  : List Germplasm Attributes
- [`brapi_crosses()`](https://josh45-source.github.io/brapiR2/reference/brapi_crosses.md)
  : List Crosses
- [`brapi_crossing_projects()`](https://josh45-source.github.io/brapiR2/reference/brapi_crossing_projects.md)
  : List Crossing Projects
- [`brapi_seed_lots()`](https://josh45-source.github.io/brapiR2/reference/brapi_seed_lots.md)
  : List Seed Lots
- [`brapi_search_germplasm()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_germplasm.md)
  : Search Germplasm

## Phenotyping Module

Observations, variables, traits, and analysis-ready data.

- [`brapi_observation_units()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_units.md)
  : List Observation Units
- [`brapi_observations()`](https://josh45-source.github.io/brapiR2/reference/brapi_observations.md)
  : List Observations
- [`brapi_observation_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_observation_variables.md)
  : List Observation Variables
- [`brapi_traits()`](https://josh45-source.github.io/brapiR2/reference/brapi_traits.md)
  : List Traits
- [`brapi_scales()`](https://josh45-source.github.io/brapiR2/reference/brapi_scales.md)
  : List Scales
- [`brapi_methods()`](https://josh45-source.github.io/brapiR2/reference/brapi_methods.md)
  : List Methods
- [`brapi_images()`](https://josh45-source.github.io/brapiR2/reference/brapi_images.md)
  : List Images
- [`brapi_events()`](https://josh45-source.github.io/brapiR2/reference/brapi_events.md)
  : List Events
- [`brapi_search_observations()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_observations.md)
  : Search Observations
- [`brapi_search_variables()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_variables.md)
  : Search Observation Variables
- [`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
  : Get Study Data in Wide Format

## Genotyping Module

Variants, genotype calls, allele matrices, and genomic selection
helpers.

- [`brapi_samples()`](https://josh45-source.github.io/brapiR2/reference/brapi_samples.md)
  : List Samples
- [`brapi_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_variants.md)
  : List Variants (Markers/SNPs)
- [`brapi_variant_sets()`](https://josh45-source.github.io/brapiR2/reference/brapi_variant_sets.md)
  : List Variant Sets (Datasets)
- [`brapi_calls()`](https://josh45-source.github.io/brapiR2/reference/brapi_calls.md)
  : List Genotype Calls
- [`brapi_call_sets()`](https://josh45-source.github.io/brapiR2/reference/brapi_call_sets.md)
  : List Call Sets (Samples with Genotype Data)
- [`brapi_references()`](https://josh45-source.github.io/brapiR2/reference/brapi_references.md)
  : List References (Chromosomes/Contigs)
- [`brapi_reference_sets()`](https://josh45-source.github.io/brapiR2/reference/brapi_reference_sets.md)
  : List Reference Sets (Genome Assemblies)
- [`brapi_allele_matrix()`](https://josh45-source.github.io/brapiR2/reference/brapi_allele_matrix.md)
  : Get Allele Matrix
- [`brapi_search_variants()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_variants.md)
  : Search Variants
- [`brapi_search_calls()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_calls.md)
  : Search Genotype Calls
- [`brapi_get_dosage_matrix()`](https://josh45-source.github.io/brapiR2/reference/brapi_get_dosage_matrix.md)
  : Get Dosage Matrix for Genomic Selection
- [`brapi_get_marker_map()`](https://josh45-source.github.io/brapiR2/reference/brapi_get_marker_map.md)
  : Get Marker Map

## Caching & Performance

Response caching and parallel data fetching.

- [`brapi_cache_enable()`](https://josh45-source.github.io/brapiR2/reference/brapi_cache_enable.md)
  : Enable Response Caching
- [`brapi_cache_clear()`](https://josh45-source.github.io/brapiR2/reference/brapi_cache_clear.md)
  : Clear the Response Cache
- [`brapi_fetch_parallel()`](https://josh45-source.github.io/brapiR2/reference/brapi_fetch_parallel.md)
  : Parallel Batch Fetching
