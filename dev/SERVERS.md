# Server survey

Working notes for the rOpenSci review. Not part of the package; `dev/`
is `.Rbuildignore`d.

`dev/survey-servers.R` runs one request against each of ten endpoints on
every reachable server and records what happened, to `dev/server-survey.rds`.
One request per endpoint, not a paginated fetch: the question is whether a
server answers, not how much data it holds.

Last run: 19 September 2026. 62 of 80 probes succeeded.

## Servers

| Server | Implementation | Auth for reads | Services | Probes passed |
|---|---|---|---|---|
| BrAPI test server | reference | no | 148 | 10/10 |
| Cassavabase | Breedbase | no | 118 | 7/10 |
| Sweetpotatobase | Breedbase | no | 118 | 9/10 |
| Coffeabase | Breedbase | no | 117 | 10/10 |
| Citrusgreening | Breedbase | no | 117 | 8/10 |
| USDA-GRIN | GRIN-Global | no | 13 | 2/10 |
| T3/Oat Sandbox | Breedbase | yes | 118 | 8/10 |
| T3/Wheat Sandbox | Breedbase | yes | 118 | 8/10 |

T3 accounts are per instance; oat credentials do not work on wheat.
T3 requires authentication even for `/serverinfo`, which the specification
treats as the discovery endpoint. The others do not.

## What failed

| Server | Endpoint | Seconds | Result |
|---|---|---|---|
| Cassavabase | `/samples` | 30.0 | no response within the 30s timeout |
| Cassavabase | `/trials` | 30.0 | no response within the 30s timeout |
| Cassavabase | `/variantsets` | 30.0 | no response within the 30s timeout |
| Citrusgreening | `/studies` | 1.3 | BrAPI request failed (HTTP 500). |
| Citrusgreening | `/variantsets` | 1.3 | BrAPI request failed (HTTP 500). |
| Sweetpotatobase | `/samples` | 1.6 | BrAPI request failed (HTTP 500). |
| T3/Oat Sandbox | `/samples` | 21.1 | could not connect (transient) |
| T3/Oat Sandbox | `/variantsets` | 30.0 | no response within the 30s timeout |
| T3/Wheat Sandbox | `/trials` | 30.0 | no response within the 30s timeout |
| T3/Wheat Sandbox | `/variantsets` | 30.1 | no response within the 30s timeout |
| USDA-GRIN | `/germplasm` | 0.4 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/programs` | 0.3 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/samples` | 0.4 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/studies` | 0.3 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/traits` | 0.6 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/trials` | 0.3 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/variables` | 0.3 | BrAPI request failed (HTTP 404). |
| USDA-GRIN | `/variantsets` | 0.3 | BrAPI request failed (HTTP 404). |

## Findings

- GRIN-Global serves BrAPI under /gringlobal/brapi/. Fixed by adding a
  `path` argument to brapi_connection().
- T3 emits JSON objects with varying key order between records in one
  response. On oat-sandbox study 6882, 75 of 4613 observations were
  affected. Fixed by normalising key order in parse_brapi_result().
- Cassavabase advertises `people/{peopleDbId}`; the spec says
  `people/{personDbId}`. Also advertises search/seasons, which the test
  server does not.
- No trailing whitespace on observation values across 21 studies
  (oat-sandbox, wheat-sandbox, Cassavabase; ~174,000 values).
- USDA-GRIN implements only 13 services: germplasm, locations, methods,
  observations, people and traits, each with a by-ID variant, plus
  commoncropnames. No studies, trials, programs, search or genotyping,
  and it does not advertise serverinfo in its own list. brapi_studies()
  returns 404 there, correctly.
- Both T3 sandboxes advertise 118 services, the same count as Cassavabase.
- The public test server ignores the `germplasmDbId` filter on `/pedigree`:
  a request for germplasm1 returns germplasm1 and germplasm3. Both
  by-germplasm pedigree functions now filter client-side as well.
- `/germplasm/{id}/pedigree` (8 columns) and `/pedigree?germplasmDbId=`
  (15 columns) return different shapes on both T3 sandboxes; `pedigree`
  becomes `pedigreeString`, and relatives come back as tidy tibbles
  rather than raw nested lists.
- An unfiltered brapi_germplasm() does not complete on Cassavabase or
  wheat-sandbox: a single request answers in under a second, but
  brapi_get() walks every page, and these servers hold hundreds of
  thousands of records. Cassavabase took 18 minutes to walk 8,539 studies.
  There is no way to ask brapi_get() for just the first page.
- /locations/{locationDbId} works on all four reachable servers. Column
  counts differ (21 on the test server, 19 on Cassavabase, oat-sandbox
  and GRIN), since servers return different optional fields.

## Reproducers

- brapi_study_data() failure: oat-sandbox studyDbId 6882 (@dwaring87).

## Not reached

- BMS, EBS: institutional accounts needed.
- GIGWA, Germinate: no public v2 instance found.
- Ricebase answers but returns HTTP 500 even on `/serverinfo`.
- Yambase, Musabase: authenticate even for `/serverinfo`; no account.
