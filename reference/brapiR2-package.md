# brapiR2: A Tidyverse-Native Client for the 'BrAPI' v2 (Breeding API) Specification

Provides pipe-friendly, stateless read access to the Breeding API
('BrAPI') v2.1 specification, an open community standard for plant
breeding data interchange maintained by the BrAPI project
<https://brapi.org>. Wraps 32 of the 36 'BrAPI' v2.1 entities across all
four modules, Core, Germplasm, Phenotyping, and Genotyping, covering 56
of the specification's 138 retrieval ('GET' and search) endpoints and
returning tidy tibbles ready for analysis. Write and update endpoints
are out of scope by design. Features include automatic pagination, async
search handling, response caching, parallel batch fetching, and
convenience functions for genomic selection workflows (e.g. dosage
matrix extraction). Designed for plant breeders and bioinformaticians
who need programmatic access to 'BreedBase', 'BMS', 'EBS', 'GIGWA',
'Germinate', and any 'BrAPI'-compliant server.

## See also

Useful links:

- <https://github.com/josh45-source/brapiR2>

- <https://josh45-source.github.io/brapiR2/>

- Report bugs at <https://github.com/josh45-source/brapiR2/issues>

## Author

**Maintainer**: Joash Joshua Ayo <joashjoshua789@gmail.com>
([ORCID](https://orcid.org/0009-0007-1642-0172))
