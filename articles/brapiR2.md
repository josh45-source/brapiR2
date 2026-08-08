# brapiR2

**brapiR2** provides pipe-friendly, stateless access to BrAPI v2
servers. Unlike stateful clients where you navigate by setting a
“current” program or trial, brapiR2 functions are independent — you pass
a connection object and get a tibble back. This makes them ideal for
scripting, pipelines, and building downstream tools.

## Installation

If you don’t already have **remotes** installed, run
`install.packages("remotes")` first.

``` r

# Not run here: this would reinstall the package while building its own
# documentation.
remotes::install_github("josh45-source/brapiR2")
```

## Connecting to a Server

The examples below run live against the public BrAPI test server, which
requires no authentication.

``` r

library(brapiR2)

con <- brapi_connection("https://test-server.brapi.org")
con
#> 
#> ── BrAPI Connection
#> • Server: <https://test-server.brapi.org>
#> • Version: v2
#> • Auth: ✗ no token
#> • Page size: 1000
#> • Timeout: 120s
#> • Cache: disabled
```

Every function takes `con` as its first argument. No global state is
modified.

## Exploring Programs and Trials

BrAPI organises breeding data as a nesting of four levels, and the calls
below walk down it. A **program** is a long-running breeding effort with
a continuing objective, such as a maize program developing mid-altitude
tropical hybrids; it persists across decades. A **trial** groups
experiments that share a purpose within that program, typically one
season’s worth of work, such as the 2022 advanced yield trials. A
**study** is a single trial grown at one location in one season, which
is the level at which plots physically exist and measurements are
actually taken. Below that sit **observation units**, the individual
plots, plants or samples that carry the measurements themselves.

You narrow from one level to the next because each level’s identifier is
the filter for the one below it. In practice you rarely know a
`studyDbId` up front; you know you want last season’s yield trials from
a particular program, and you find your way down. Note that what a
breeder calls an “environment” in a multi-environment analysis
corresponds to a BrAPI study, not a location, since the same site in two
seasons is two environments.

``` r

library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# List all breeding programs
programs <- brapi_programs(con)
programs
#> # A tibble: 3 × 12
#>   additionalInfo externalReferences abbreviation commonCropName documentationURL
#>   <list>         <list>             <chr>        <chr>          <chr>           
#> 1 <named list>   <list [1]>         P1           Tomatillo      https://brapi.o…
#> 2 <named list>   <list [1]>         P2           Tomatillo      https://brapi.o…
#> 3 <named list>   <list [1]>         P3           Paw Paw        https://brapi.o…
#> # ℹ 7 more variables: leadPersonDbId <chr>, leadPersonName <chr>,
#> #   objective <chr>, programName <chr>, programType <chr>,
#> #   fundingInformation <chr>, programDbId <chr>

# List trials in the first program
trials <- brapi_trials(con, programDbId = programs$programDbId[1])
trials
#> # A tibble: 1 × 16
#>   active additionalInfo   commonCropName contacts   datasetAuthorships
#>   <lgl>  <list>           <chr>          <list>     <list>            
#> 1 TRUE   <named list [1]> Tomatillo      <list [1]> <list [1]>        
#> # ℹ 11 more variables: documentationURL <chr>, endDate <chr>,
#> #   externalReferences <list>, programDbId <chr>, programName <chr>,
#> #   publications <list>, startDate <chr>, trialDescription <chr>,
#> #   trialName <chr>, trialPUI <chr>, trialDbId <chr>

# List studies within that trial
studies <- brapi_studies(con, trialDbId = trials$trialDbId[1])
studies
#> # A tibble: 1 × 29
#>   additionalInfo   externalReferences active commonCropName contacts  
#>   <list>           <list>             <lgl>  <chr>          <list>    
#> 1 <named list [1]> <list [1]>         TRUE   Tomatillo      <list [1]>
#> # ℹ 24 more variables: culturalPractices <chr>, dataLinks <list>,
#> #   documentationURL <chr>, endDate <chr>, environmentParameters <list>,
#> #   experimentalDesign <list>, growthFacility <list>, lastUpdate <list>,
#> #   license <chr>, locationDbId <chr>, locationName <chr>,
#> #   observationLevels <list>, observationUnitsDescription <chr>,
#> #   seasons <list>, startDate <chr>, studyCode <chr>, studyDescription <chr>,
#> #   studyName <chr>, studyPUI <chr>, studyType <chr>, trialDbId <chr>, …
```

## Fetching Phenotypic Data

The `/observations` endpoint returns data in long format, one row per
measurement, with the trait identified in a column and the value in
another. That is the right shape for transport and the wrong shape for
analysis: nearly every R modelling function expects one row per
experimental unit and one column per variable.

[`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
does that reshaping for you. It fetches the study’s observations, pivots
traits into columns, and joins the germplasm and plot identifiers you
need to link phenotypes back to genotypes or to a field layout. Doing
this by hand is not difficult, but it is fiddly in ways that are easy to
get subtly wrong, particularly when an observation unit carries more
than one value for the same trait. Repeated measurements are kept as
list-columns rather than silently averaged or dropped, which is why the
summary below unnests before taking means. The function also falls back
to fetching all observations and filtering client-side when a server
does not honour the `studyDbId` filter, so it returns data on servers
where a direct
[`brapi_observations()`](https://josh45-source.github.io/brapiR2/reference/brapi_observations.md)
call would come back empty.

``` r

# Get analysis-ready wide format: one row per plot, one column per trait
data <- brapi_study_data(con, studies$studyDbId[1])
data
#> # A tibble: 2 × 6
#>   observationUnitDbId observationUnitName germplasmDbId germplasmName  studyDbId
#>   <chr>               <chr>               <chr>         <chr>          <chr>    
#> 1 observation_unit1   Plot 1              germplasm1    Tomatillo Fan… study1   
#> 2 observation_unit2   Plot 2              germplasm2    Tomatillo Fan… study1   
#> # ℹ 1 more variable: `Corn Stalk Height` <list>
```

The public test server’s studies currently have no recorded
observations, so
[`brapi_study_data()`](https://josh45-source.github.io/brapiR2/reference/brapi_study_data.md)
returns an empty tibble and a warning rather than fabricated numbers —
this is the function’s real, documented behavior when a study has no
data, not a bug in the example. Downstream code should check for this:

``` r

if (nrow(data) > 0) {
  trait_cols <- setdiff(
    names(data),
    c(
      "observationUnitDbId", "observationUnitName",
      "germplasmDbId", "germplasmName", "studyDbId", "studyName"
    )
  )
  # Some observation units have more than one recorded value for the same
  # trait (repeated measurements), which brapi_study_data() keeps as a
  # list-column. Unnest those into one row per observation before
  # summarising, so mean() sees plain numbers either way.
  data |>
    tidyr::unnest_longer(dplyr::any_of(trait_cols)) |>
    mutate(across(all_of(trait_cols), as.numeric)) |>
    summarise(across(all_of(trait_cols), \(x) mean(x, na.rm = TRUE)))
} else {
  cat("No observations available for this study on the public test server.\n")
}
#> # A tibble: 1 × 1
#>   `Corn Stalk Height`
#>                 <dbl>
#> 1                  25
```

## Fetching Genotypic Data

A **variant set** is a genotyping dataset: a defined panel of markers
scored on a defined set of samples, usually corresponding to one
genotyping run or one platform. A server may hold several, and they will
differ in marker density, in which individuals were scored, and often in
reference genome build, so picking the right one matters.

The dosage matrix is the form nearly every downstream analysis wants.
Each cell counts how many copies of the alternate allele an individual
carries at that marker, so for diploid maize the values are 0 for
homozygous reference, 1 for heterozygous, 2 for homozygous alternate,
and `NA` where the call failed. For polyploids the range extends to the
ploidy level, which is why the function returns counts rather than a
genotype string. Representing genotypes numerically this way is what
allows them to enter a mixed model as a design matrix: additive marker
effects are then simply regression coefficients on allele count.

``` r

# List available variant sets (genotyping datasets)
vsets <- brapi_variant_sets(con)
vsets
#> # A tibble: 1 × 11
#>   additionalInfo   externalReferences analysis   availableFormats callSetCount
#>   <list>           <list>             <list>     <list>                  <int>
#> 1 <named list [1]> <list [1]>         <list [1]> <list [3]>                 13
#> # ℹ 6 more variables: referenceSetDbId <chr>, studyDbId <chr>,
#> #   variantCount <int>, variantSetDbId <chr>, variantSetName <chr>,
#> #   metadataFields <list>

vs_id <- vsets$variantSetDbId[1]

# Get marker chromosome / position map
markers <- brapi_get_marker_map(con, vs_id)
markers
#> # A tibble: 20 × 4
#>    variantDbId variantName referenceName start
#>    <chr>       <chr>       <lgl>         <lgl>
#>  1 variant01   M1          NA            NA   
#>  2 variant02   M2          NA            NA   
#>  3 variant03   M3          NA            NA   
#>  4 variant04   M4          NA            NA   
#>  5 variant05   M5          NA            NA   
#>  6 variant06   M6          NA            NA   
#>  7 variant07   M7          NA            NA   
#>  8 variant08   M8          NA            NA   
#>  9 variant09   M9          NA            NA   
#> 10 variant10   M10         NA            NA   
#> 11 variant11   M11         NA            NA   
#> 12 variant12   M12         NA            NA   
#> 13 variant13   M13         NA            NA   
#> 14 variant14   M14         NA            NA   
#> 15 variant15   M15         NA            NA   
#> 16 variant16   M16         NA            NA   
#> 17 variant17   M17         NA            NA   
#> 18 variant18   M18         NA            NA   
#> 19 variant19   M19         NA            NA   
#> 20 variant20   M20         NA            NA
```

On this server `referenceName` and `start` are not populated for these
markers (both come back `NA`) — the map’s identity and name columns are
still real and usable.

``` r

# Get dosage matrix for genomic selection (samples x markers, values 0/1/2)
dosage <- brapi_get_dosage_matrix(con, vs_id)
#> ℹ Fetching allele matrix for variant set "variantset1"...
#> ℹ Encoding 260 genotype calls as allele dosages...
#> ✔ Dosage matrix ready: 13 samples x 20 markers.
dim(dosage)
#> [1] 13 20
dosage[seq_len(min(3, nrow(dosage))), seq_len(min(5, ncol(dosage)))]
#>           variant01 variant02 variant03 variant04 variant05
#> callset01         0         0         0         0         0
#> callset02         1         0        NA        NA        NA
#> callset03         1         0         1         1         0
```

## Authentication

Most production BrAPI servers require authentication. These calls need
your own server and credentials, so they are shown but not run here.

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

### Handling Credentials Safely

The example above reads a token from an environment variable rather than
writing it as a literal string, and that’s deliberate: a password or
token typed directly into a script gets committed to version control the
moment someone runs `git add`, and stays in the project’s history even
after it’s “removed” in a later commit. There are two safer places to
keep it.

**`.Renviron` and
[`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html).** For scripts
you run yourself, put credentials in a `.Renviron` file (in your home
directory for all projects, or in the project directory for that project
only) as `NAME=value` pairs, one per line:

    BRAPI_TOKEN=abc123...
    BRAPI_PASSWORD=my_password

R reads `.Renviron` automatically at startup, so after restarting your R
session the values are available via
[`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html):

``` r

con <- brapi_connection("https://my-breedbase.org")
con <- brapi_login(
  con, Sys.getenv("BRAPI_USERNAME"), Sys.getenv("BRAPI_PASSWORD")
)
```

Add `.Renviron` to `.gitignore` so it never gets committed.
`usethis::edit_r_environ()` opens the right file for you.

**The keyring package.** For credentials you want stored in your
operating system’s own credential manager (Keychain on macOS, Credential
Manager on Windows, Secret Service on Linux) rather than in a plaintext
file, use [keyring](https://cran.r-project.org/package=keyring).
`key_set()` prompts interactively for a secret and stores it;
`key_get()` retrieves it later, in this session or a future one, without
the value ever appearing in your script or your R history:

``` r

# Run once, interactively - prompts for the password and stores it
keyring::key_set("brapiR2_my-breedbase", username = "my_username")

# In scripts, from then on:
con <- brapi_connection("https://my-breedbase.org")
con <- brapi_login(
  con,
  username = "my_username",
  password = keyring::key_get("brapiR2_my-breedbase", username = "my_username")
)
```

Either approach keeps the secret out of the script itself, out of shell
history, and out of anything you might `git commit` or share.

## Caching and Parallel Fetching

These run against the public test server again (caching and parallel
fetching don’t need authentication).

``` r

# Enable caching — repeated calls within the TTL return instantly
cache_dir <- tempfile("brapi_cache_")
dir.create(cache_dir)
perf_con <- brapi_cache_enable(con, ttl = 3600, dir = cache_dir)
#> ✔ Caching enabled at /tmp/RtmpGuYt9Z/brapi_cache_1f2e498a3484 (TTL: 3600s)

# First call: hits the server
invisible(brapi_programs(perf_con))

# Second call: reads from disk (sub-millisecond)
brapi_programs(perf_con)
#> ℹ Using cached response for /programs.
#> # A tibble: 3 × 12
#>   additionalInfo externalReferences abbreviation commonCropName documentationURL
#>   <list>         <list>             <chr>        <chr>          <chr>           
#> 1 <named list>   <list [1]>         P1           Tomatillo      https://brapi.o…
#> 2 <named list>   <list [1]>         P2           Tomatillo      https://brapi.o…
#> 3 <named list>   <list [1]>         P3           Paw Paw        https://brapi.o…
#> # ℹ 7 more variables: leadPersonDbId <chr>, leadPersonName <chr>,
#> #   objective <chr>, programName <chr>, programType <chr>,
#> #   fundingInformation <chr>, programDbId <chr>

# Clear all cached files
brapi_cache_clear(perf_con)
#> ✔ Cleared 1 cached response(s).
```

[`brapi_fetch_parallel()`](https://josh45-source.github.io/brapiR2/reference/brapi_fetch_parallel.md)
does not set a parallel backend itself - it runs against whatever
`future` plan is already active, sequential by default. The future
package’s best-practices vignette is explicit that the choice of backend
belongs to the caller, not to a package: a function that quietly sets
and restores a plan on every call still mutates session-wide state you
didn’t ask it to touch, and can silently replace a plan you configured
deliberately (a specific worker count, a cluster spanning several
machines, callr workers for extra isolation). So it’s your call to make,
before this function runs:

``` r

future::plan(future::multisession, workers = 2)

# Fetch study data from multiple studies in parallel (all studies on the
# server, not just the one attached to the trial filtered above)
study_ids <- brapi_studies(con)$studyDbId
all_data <- brapi_fetch_parallel(perf_con, brapi_study_data, study_ids)
#> ℹ Fetching 3 items...
#> ℹ Using cached response for /observations.
#> ! No observations found for study "study2".
#> ℹ Using cached response for /observations.
#> ! No observations found for study "study3".
#> ✔ Fetched 2 rows from 3 sources.
all_data
#> # A tibble: 2 × 6
#>   observationUnitDbId observationUnitName germplasmDbId germplasmName  studyDbId
#>   <chr>               <chr>               <chr>         <chr>          <chr>    
#> 1 observation_unit1   Plot 1              germplasm1    Tomatillo Fan… study1   
#> 2 observation_unit2   Plot 2              germplasm2    Tomatillo Fan… study1   
#> # ℹ 1 more variable: `Corn Stalk Height` <list>
```

As above, this server’s studies have no observations, so `all_data` is
an empty tibble here too — the call itself, and the parallel-fetch
mechanics, are real.

Since you set the plan, shutting the workers back down when you’re done
with them is your responsibility too, not something the package does for
you on exit:

``` r

future::plan(future::sequential)
```

------------------------------------------------------------------------

## Comparison with QBMS

[QBMS](https://cran.r-project.org/package=QBMS) is a well-established R
package for BrAPI access that has been widely adopted in the breeding
community. brapiR2 and QBMS are **complementary tools designed for
different workflows**.

| Feature | QBMS | brapiR2 |
|----|----|----|
| Style | Stateful (set program → set trial → set study) | Stateless (pass `con` everywhere) |
| Returns | Data frames | Tibbles (tidy, list-columns for nested data) |
| Pipe-friendly | Partial | Yes, all functions follow `f(con, ...)` |
| Caching | No | Yes, disk-based with TTL |
| Parallel fetch | No | Via the caller’s own `future` backend |
| Genotypics | Limited | Full (allele matrix, dosage matrix, marker map) |
| BrAPI version | v1 + v2 | v2 only |
| Authentication | Yes | Yes |

### Same workflow, different style

The examples below use a private BreedBase-style server and credentials,
so they are illustrative only.

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

## References

- Selby, P., Abbeloos, R., Backlund, J.E., et al., & The BrAPI
  Consortium (2019). BrAPI — an application programming interface for
  plant breeding applications. *Bioinformatics*, 35(20), 4147–4155.
  <https://doi.org/10.1093/bioinformatics/btz190>

Choose QBMS for interactive exploration in the console. Choose brapiR2
for reproducible scripts, pipelines, or when you need genotypic data and
caching. Many users use both.
