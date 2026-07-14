# Getting Started with brapiR2

## Introduction

**brapiR2** provides pipe-friendly, stateless access to BrAPI v2
servers. Unlike stateful clients where you navigate by setting a
“current” program or trial, brapiR2 functions are independent — you pass
a connection object and get a tibble back. This makes them ideal for
scripting, pipelines, and building downstream tools.

## Installation

If you don’t already have **remotes** installed, run
`install.packages("remotes")` first.

``` r

remotes::install_github("josh45-source/brapiR2")
```

## Connecting to a Server

``` r

library(brapiR2)

# The BrAPI test server is public and requires no authentication
con <- brapi_connection("https://test-server.brapi.org")
con
#> -- BrAPI Connection --
#> Server : https://test-server.brapi.org
#> Version: v2
#> Token  : <none>
#> Cache  : disabled
```

Every function takes `con` as its first argument. No global state is
modified.

## Exploring Programs and Trials

``` r

library(dplyr)

# List all breeding programs
programs <- brapi_programs(con)
programs
#> # A tibble: 3 x 10
#>   programDbId programName    abbreviation commonCropName
#>   <chr>       <chr>          <chr>        <chr>
#> 1 program1    Wheat Breeding WB           Wheat
#> 2 program2    Maize Program  MP           Maize
#> 3 program3    Rice Research  RR           Rice
#> # ... with 6 more variables: programType <chr>, leadPersonDbId <chr>,
#> #   leadPersonName <chr>, documentationURL <list>, externalReferences <list>,
#> #   additionalInfo <list>

# List trials in the first program
trials <- brapi_trials(con, programDbId = programs$programDbId[1])
trials
#> # A tibble: 3 x 12
#>   trialDbId trialName        programDbId programName    active
#>   <chr>     <chr>            <chr>       <chr>          <lgl>
#> 1 trial1    Yield Trial 2022 program1    Wheat Breeding TRUE
#> 2 trial2    Drought Study    program1    Wheat Breeding TRUE
#> 3 trial3    Regional Test    program1    Wheat Breeding FALSE

# List studies within a trial
studies <- brapi_studies(con, trialDbId = trials$trialDbId[1])
studies
#> # A tibble: 3 x 15
#>   studyDbId studyName       trialDbId trialName        locationDbId
#>   <chr>     <chr>           <chr>     <chr>            <chr>
#> 1 study1    Ithaca 2022     trial1    Yield Trial 2022 location1
#> 2 study2    Geneva 2022     trial1    Yield Trial 2022 location2
#> 3 study3    Riverhead 2022  trial1    Yield Trial 2022 location3
```

## Fetching Phenotypic Data

``` r

# Get analysis-ready wide format: one row per plot, one column per trait
data <- brapi_study_data(con, "study1")
data
#> # A tibble: 2 x 6
#>   observationUnitDbId observationUnitName germplasmDbId germplasmName
#>   <chr>               <chr>               <chr>         <chr>
#> 1 ou1                 Plot 1              germ1         Variety_A
#> 2 ou2                 Plot 2              germ2         Variety_B
#> # ... with 2 more variables: `Corn Stalk Height` <chr>,
#> #                             `Plant Height` <chr>

# All traits become columns — ready for analysis
data |>
  mutate(across(c(`Corn Stalk Height`, `Plant Height`), as.numeric)) |>
  summarise(across(where(is.numeric), mean, na.rm = TRUE))
```

## Fetching Genotypic Data

``` r

# List available variant sets (genotyping datasets)
vsets <- brapi_variant_sets(con)
vsets
#> # A tibble: 2 x 8
#>   variantSetDbId variantSetName callSetCount variantCount
#>   <chr>          <chr>                 <int>        <int>
#> 1 variantSet1    SNP50K                   13           20
#> 2 variantSet2    GBS_v1                   50         1500

# Get marker chromosome / position map
markers <- brapi_get_marker_map(con, "variantSet1")
markers
#> # A tibble: 20 x 4
#>    variantDbId variantName   referenceName  start
#>    <chr>       <chr>         <chr>          <int>
#>  1 marker1     SNP_001       1A                NA
#>  2 marker2     SNP_002       1A                NA
#>  # ...

# Get dosage matrix for genomic selection (samples x markers, values 0/1/2)
dosage <- brapi_get_dosage_matrix(con, "variantSet1")
dim(dosage)
#> [1] 13 20        # 13 samples, 20 markers
dosage[1:3, 1:5]
#>            marker1 marker2 marker3 marker4 marker5
#> callset1         0       1       2       0       1
#> callset2         2       0       1       2       0
#> callset3         1       1       0       1       2
```

## Authentication

Most production BrAPI servers require authentication:

``` r

# Username/password login - used by BreedBase, BMS, and Germinate
con <- brapi_connection("https://my-breedbase.org")
con <- brapi_login(con, "username", "password")

# OAuth 2.0 (EBS and similar)
con <- brapi_login_oauth2(
  con,
  client_id     = "my_id",
  client_secret = "my_secret",
  authorize_url = "https://auth.example.org/authorize",
  access_url    = "https://auth.example.org/token"
)

# Bearer token (GIGWA, custom servers)
con <- brapi_set_token(con, Sys.getenv("BRAPI_TOKEN"))
```

## Caching and Parallel Fetching

``` r

# Enable caching — repeated calls within the TTL return instantly
con <- brapi_cache_enable(con, ttl = 3600)
#> v Caching enabled at ~/.cache/brapiR2 (TTL: 3600s)

# First call: hits the server
programs <- brapi_programs(con)

# Second call: reads from disk (sub-millisecond)
programs <- brapi_programs(con)
#> i Using cached response for /programs.

# Clear all cached files
brapi_cache_clear(con)
#> v Cleared 5 cached response(s).

# Fetch study data from multiple environments in parallel
study_ids <- c("study1", "study2", "study3")
all_data <- brapi_fetch_parallel(con, brapi_study_data, study_ids, .workers = 3)
#> i Fetching 3 items across 3 workers...
#> v Fetched 6 rows from 3 sources.
all_data
#> # A tibble: 6 x 7
#>   observationUnitDbId studyDbId studyName  germplasmName  `Corn Stalk Height`
#>   <chr>               <chr>     <chr>      <chr>          <chr>
#> 1 ou1                 study1    Ithaca     Variety_A      180
#> 2 ou2                 study1    Ithaca     Variety_B      195
#> # ...
```

------------------------------------------------------------------------

## Comparison with QBMS

[QBMS](https://icarda-git.github.io/QBMS/) is a well-established R
package for BrAPI access that has been widely adopted in the breeding
community. brapiR2 and QBMS are **complementary tools designed for
different workflows**.

| Feature | QBMS | brapiR2 |
|----|----|----|
| Style | Stateful (set program → set trial → set study) | Stateless (pass `con` everywhere) |
| Returns | Data frames | Tibbles (tidy, list-columns for nested data) |
| Pipe-friendly | Partial | Yes, all functions follow `f(con, ...)` |
| Caching | No | Yes, disk-based with TTL |
| Parallel fetch | No | Yes, via `furrr` |
| Genotypics | Limited | Full (allele matrix, dosage matrix, marker map) |
| BrAPI version | v1 + v2 | v2 only |
| Authentication | Yes | Yes |

### Same workflow, different style

**QBMS** — navigational, stateful:

``` r

library(QBMS)

set_crop("Wheat")
login_bms("https://my-bms.org", "user", "pass")

list_programs()
set_program("Wheat Breeding")

list_trials()
set_trial("Yield Trial 2022")

list_studies()
set_study("Ithaca 2022")

data <- get_study_data()
```

**brapiR2** — functional, pipe-friendly:

``` r

library(brapiR2)
library(dplyr)

con <- brapi_connection("https://my-bms.org") |>
  brapi_login("user", "pass")

data <- brapi_programs(con) |>
  filter(programName == "Wheat Breeding") |>
  pull(programDbId) |>
  (\(pid) brapi_trials(con, programDbId = pid))() |>
  filter(trialName == "Yield Trial 2022") |>
  pull(trialDbId) |>
  (\(tid) brapi_studies(con, trialDbId = tid))() |>
  filter(studyName == "Ithaca 2022") |>
  pull(studyDbId) |>
  brapi_study_data(con = con)
```

Choose QBMS for interactive exploration in the console. Choose brapiR2
for reproducible scripts, pipelines, or when you need genotypic data and
caching. Many users use both.
