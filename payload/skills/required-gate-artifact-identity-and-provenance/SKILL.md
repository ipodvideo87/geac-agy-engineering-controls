---
name: required-gate-artifact-identity-and-provenance
description: "STOP AND CHECK IDENTITY AND PROVENANCE: Use this skill whenever a claim depends on sameness, byte equality, artifact identity, generation, lineage, derivation, provenance, hashes, paths, metadata, IDs, timestamps, namespaces, or transfer history."
---
# GEAC X1 — Engineering Identity and Provenance

## COMPONENT_ID
`IDENTITY_PROVENANCE_TIME`

## ROLE
Keep distinct identity dimensions and prohibit metadata, names, paths, fingerprints, timestamps, or numeric overlap from silently becoming stronger identity/provenance claims.

## ACTIVATES_WHEN
The task compares objects/artifacts/records/generations, uses hashes/metadata/IDs, discusses transfer or origin, or moves claims across time.

## REQUIRES
Exact objects, required identity dimension, comparison/binding evidence, and relevant time/scope.

## CONSUMES
Classified evidence, equality/comparison results, provenance fields, generation/time information.

## PRODUCES
Dimensioned equality/identity/provenance states and explicit missing identity relations.

## CONSTRAINS
Keep separate representation equality, byte equality, artifact identity, generation identity, semantic-entity identity, provenance, and temporal continuity.

## MAY_ACTIVATE
Evidence/source, transitions, testing, history, reporting.

## PROHIBITED_TRANSITIONS
`SAME_NAME(A,B) -/-> SAME_ARTIFACT(A,B)`  
`SAME_PATH(A_t1,A_t2) -/-> SAME_BYTES(A_t1,A_t2)`  
`SAME_SIZE(A,B) -/-> SAME_BYTES(A,B)`  
`NEAR_TIMESTAMP(A,B) -/-> SAME_GENERATION(A,B)`  
`SAME_METADATA(A,B) -/-> SAME_ARTIFACT(A,B)`  
`SAME_METADATA(A,B) -/-> ACQUISITION_PROVENANCE(B)`  
`NEAR_TIMESTAMP(A,B) -/-> ACQUISITION_PROVENANCE(B)`  

Combinations of name, size, path, timestamp, or other metadata do not establish a copy, transfer, staging, derivation, lineage, generation, or acquisition event. Without event-binding evidence, report only the metadata relation actually established and keep the provenance relation `NOT_ESTABLISHED`. Do not introduce an unsupplied provenance event merely as a compatibility explanation for the metadata.

`SAME_FINGERPRINT_VALUE(A,B) -/-> SAME_SEMANTIC_ENTITY(A,B)` without established fingerprint semantics and namespace relation.  
`SAME_NUMERIC_ID(A,B) -/-> SAME_SEMANTIC_ENTITY(A,B)` across unbound namespaces.  
`CURRENT_LOCATION(O) -/-> ACQUISITION_PROVENANCE(O)`  
`TRUE_NOW(P) -/-> TRUE_EARLIER(P)`

`SAME_BYTES` does not by itself establish same generation, origin, transfer history, or future immutability.

## FALLBACK
If the required identity relation is missing: preserve any weaker equality actually established and set the stronger identity proposition `NOT_ESTABLISHED`.

## HANDOFF
Provide exact identity/provenance/time state to transition, testing, criteria, history, and reporting controls.

## REENTRY
Re-enter after mutation, new comparison/binding evidence, or time/generation changes that may invalidate current identity claims.

## SEMANTIC_OWNER
Canonical owner of `SAME_ARTIFACT`, `SAME_BYTES`, `SAME_GENERATION`, identity dimension, provenance fields, and temporal identity binding.
