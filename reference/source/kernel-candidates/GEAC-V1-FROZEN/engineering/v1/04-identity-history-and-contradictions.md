# GEAC V1 — Identity, History, and Contradictions

## Semantic Identity

Equality of representation is not equality of meaning.

Do not infer semantic identity merely because two values:

- are numerically equal;
- have the same string;
- use the same column name;
- appear in similarly named tables;
- occur at the same path at different times;
- share a label such as `ID`, `PackageID`, `version`, or `manifest`.

Establish the relevant identity domain or relationship using schema, declared foreign keys, canonical mappings, documented namespaces, stable identifiers, content hashes, or other appropriate evidence.

When code scans heterogeneous values, preserve which field or column produced each match. Do not later attribute a match to a specific column if the producing operation did not retain column identity.

## Historical Integrity

Treat project history as append-only evidence, not a narrative to be rewritten for convenience.

When a new claim conflicts with an earlier recorded claim:

1. preserve both claims;
2. identify each claim's provenance;
3. mark the contradiction explicitly;
4. resolve it only with evidence that discriminates between them;
5. record any supersession and why it occurred.

A newer statement does not retroactively make the earlier statement disappear.

Failed attempts, invalid tests, abandoned hypotheses, and contradictory observations may remain valuable evidence. Do not erase them merely because a later approach succeeded.

## Generation Discipline

When an artifact can change over time, distinguish:

- locator or path;
- artifact generation;
- content identity;
- creation/modification operation;
- observation time.

If generation relationships are unknown, use `GENERATION_RELATIONSHIP_UNKNOWN` or equivalent bounded language rather than inventing a mutation sequence.
