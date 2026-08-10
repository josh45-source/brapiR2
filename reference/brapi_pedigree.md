# List Pedigree Nodes

Retrieves a filtered subset of a pedigree tree via `/pedigree` - a batch
endpoint for pulling pedigree records across many germplasm in one call.
This is different from
[`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md),
which retrieves one germplasm's immediate pedigree via the germplasm
sub-resource (`/germplasm/{germplasmDbId}/pedigree`) and must be called
once per germplasm. Use `brapi_pedigree()` (or
[`brapi_search_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_pedigree.md))
to pull pedigree records for many germplasm at once - e.g. everything in
a crop, program, or family - in one or a few requests; use
[`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)
when you already have a single germplasm ID in hand.

## Usage

``` r
brapi_pedigree(
  con,
  germplasmDbId = NULL,
  includeParents = NULL,
  includeSiblings = NULL,
  includeProgeny = NULL,
  includeFullTree = NULL,
  pedigreeDepth = NULL,
  progenyDepth = NULL,
  ...
)
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- germplasmDbId:

  Character or NULL. Filter by germplasm.

- includeParents:

  Logical or NULL. Include each node's parents.

- includeSiblings:

  Logical or NULL. Include each node's siblings.

- includeProgeny:

  Logical or NULL. Include each node's progeny.

- includeFullTree:

  Logical or NULL. Recursively include every node reachable in the
  pedigree tree.

- pedigreeDepth:

  Integer or NULL. Number of levels to include up the tree (parents,
  grandparents, ...).

- progenyDepth:

  Integer or NULL. Number of levels to include down the tree (children,
  grandchildren, ...).

- ...:

  Additional query parameters.

## Value

A tibble with one row per pedigree node. `parents`, `siblings`, and
`progeny`, when requested, are list-columns of small tibbles (one row
per relative) rather than raw nested lists or a flattened table.

## Details

Each row is one pedigree node (one germplasm). The server only includes
a node's relatives if asked: set `includeParents`, `includeSiblings`,
and/or `includeProgeny` to `TRUE` to populate the `parents`, `siblings`,
and `progeny` list-columns, each holding a small tibble of related
germplasm (`germplasmDbId`, `germplasmName`, and `parentType` - `NA` for
siblings, which have none) that you can
[`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
when you need one row per relationship rather than one row per node.
Nodes are never collapsed or flattened by default: a pedigree is
graph-shaped (each node has its own parents, siblings, and progeny
edges), and the three relation types don't share a common row shape, so
there is no lossless single flat table to fall back to.

## See also

[`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)
for one germplasm's pedigree via the germplasm sub-resource;
[`brapi_search_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_search_pedigree.md)
for the same batch retrieval via `POST`, with a fuller set of filters.

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_pedigree(con, includeParents = TRUE, includeProgeny = TRUE)
#> # A tibble: 3 × 15
#>   additionalInfo externalReferences breedingMethodDbId breedingMethodName
#>   <lgl>          <lgl>              <chr>              <chr>             
#> 1 NA             NA                 breeding_method1   Male Backcross    
#> 2 NA             NA                 breeding_method1   Male Backcross    
#> 3 NA             NA                 breeding_method1   Male Backcross    
#> # ℹ 11 more variables: crossingProjectDbId <chr>, crossingYear <int>,
#> #   defaultDisplayName <chr>, familyCode <chr>, germplasmDbId <chr>,
#> #   germplasmName <chr>, germplasmPUI <chr>, parents <list>,
#> #   pedigreeString <chr>, progeny <list>, siblings <list>
# }
```
