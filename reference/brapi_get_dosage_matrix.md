# Get Dosage Matrix for Genomic Selection

Fetches genotype data from a BrAPI server and converts it into a numeric
dosage matrix (samples × markers) compatible with genomic selection
packages like `rrBLUP`, `BGLR`, and `sommer`.

## Usage

``` r
brapi_get_dosage_matrix(con, variantSetDbId, sep = "/", unknown_string = ".")
```

## Arguments

- con:

  A
  [`brapi_connection()`](https://josh45-source.github.io/brapiR2/reference/brapi_connection.md)
  object.

- variantSetDbId:

  Character. The variant set to retrieve.

- sep:

  Character. Unphased allele separator. Default `"/"` (e.g. `"0/1"`).
  Phased calls using `"|"` are also handled automatically.

- unknown_string:

  Character. String representing missing data. Default `"."`.

## Value

A numeric matrix: rows = samples (callSetDbIds), columns = markers
(variantDbIds). Values are integer dosages (0, 1, 2 for diploids; 0–N
for polyploids). Missing calls are `NA`.

## Details

Allele dosage is computed by splitting each genotype string on `sep` (or
`"|"` for phased calls) and counting how many alleles are non-reference
(i.e. not `"0"`). Missing calls (`unknown_string`, `"."`, or `""`)
become `NA`.

## Examples

``` r
if (FALSE) { # \dontrun{
con <- brapi_connection("https://test-server.brapi.org")
dosage <- brapi_get_dosage_matrix(con, "variantset_01")
dim(dosage)
# Use with rrBLUP:
# library(rrBLUP)
# result <- mixed.solve(y = pheno$yield, Z = dosage)
} # }
```
