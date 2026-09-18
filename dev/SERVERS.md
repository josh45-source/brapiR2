# Server survey notes

Working notes for the compatibility survey (Tier 5). Not part of the
package; `dev/` is .Rbuildignored.

## Servers

| Server | Base URL | Path | Auth for reads | Services | Studies |
|---|---|---|---|---|---|
| BrAPI test server | test-server.brapi.org | brapi | no | 148 | 3 |
| Cassavabase | cassavabase.org | brapi | no | 118 | 8537 |
| T3/Oat Sandbox | oat-sandbox.triticeaetoolbox.org | brapi | yes | 118 | 2624 |
| T3/Wheat Sandbox | wheat-sandbox.triticeaetoolbox.org | brapi | yes | 118 | 9030 |
| USDA-GRIN | npgsweb.ars-grin.gov | gringlobal/brapi | no | 13 | n/a |

T3 accounts are per-instance; oat credentials do not work on wheat.
T3 requires authentication even for /serverinfo, which the spec treats
as the discovery endpoint. Cassavabase and GRIN do not.

Login worked first time on both T3 sandboxes, so the Breedbase login
bug @dwaring87 and @jmh579 hit on Cassavabase is not present there.

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
- An unfiltered brapi_germplasm() does not complete on Cassavabase
  (120s timeout at page sizes 10 and 1000) or wheat-sandbox (85+ min).
  Worth documenting, and possibly warning on large totalCount.

## Reproducers

- brapi_study_data() failure: oat-sandbox studyDbId 6882 (@dwaring87).

## Not yet reachable

- T3/Wheat, Oat, Barley production; T3/WheatCAP; barley-sandbox
- BMS, EBS: institutional accounts
- GIGWA, Germinate: no public v2 instance found yet
