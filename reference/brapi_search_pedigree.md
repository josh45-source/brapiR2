# Search Pedigree Nodes

The `POST` equivalent of
[`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md),
taking the same tree-shaping parameters plus the fuller set of filters
`/search/pedigree` accepts (crop, program, trial, study, accession
number, collection, family code, genus/species, and more - pass any of
these through `...`). See
[`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md)
for the shape of the returned tibble and its relationship to
[`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md).

## Usage

``` r
brapi_search_pedigree(
  con,
  germplasmDbIds = NULL,
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

- germplasmDbIds:

  Character vector. Filter by germplasm IDs.

- includeParents:

  Logical. Include each node's parents.

- includeSiblings:

  Logical. Include each node's siblings.

- includeProgeny:

  Logical. Include each node's progeny.

- includeFullTree:

  Logical. Recursively include every node reachable in the pedigree
  tree.

- pedigreeDepth:

  Integer. Number of levels to include up the tree.

- progenyDepth:

  Integer. Number of levels to include down the tree.

- ...:

  Additional search body parameters.

## Value

A tibble with one row per pedigree node; see
[`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md)
for column details.

## See also

[`brapi_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_pedigree.md),
[`brapi_germplasm_pedigree()`](https://josh45-source.github.io/brapiR2/reference/brapi_germplasm_pedigree.md)

## Examples

``` r
# \donttest{
con <- brapi_connection("https://test-server.brapi.org")
brapi_search_pedigree(con, includeParents = TRUE)
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
