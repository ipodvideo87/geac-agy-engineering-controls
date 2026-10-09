---
name: required-gate-evidence-source-and-claims
description: "STOP AND CHECK THE SOURCE: Use this skill whenever factual information enters engineering reasoning, a material claim depends on supplied, observed, reported, asserted, verified, absent, unknown, missing, or conflicting information, or a closed evidence boundary matters."
---
# GEAC X1 — Engineering Evidence

## COMPONENT_ID
`EVIDENCE_SOURCE`

## ROLE
Classify factual inputs without upgrading how they were acquired or what they establish.

## ACTIVATES_WHEN
Factual information enters reasoning; a prompt/source/log/report/artifact is used; source provenance matters; or the task restricts admissible information.

## REQUIRES
Exact task object and evidence boundary from the X1 kernel.

## CONSUMES
Raw information items, source relations, scope/time/object bounds.

## PRODUCES
`EVIDENCE_ITEM`, acquisition/source relation, admissibility state, and bounded unknown/absence states for downstream components.

## CONSTRAINS
No factual premise enters a material transition without classification. Preserve nested relations such as `SUPPLIED(REPORTS(scan,P))` rather than collapsing them into `P`.

## MAY_ACTIVATE
`required-gate-claim-inference-and-strengthening`, `required-gate-test-scan-results-and-verification`, `required-gate-artifact-identity-and-provenance`, `required-gate-historical-evidence-preservation`.

## PROHIBITED_TRANSITIONS
`SUPPLIED(P) -/-> OBSERVED_OBJECT(P)`  
`SUPPLIED(P) -/-> VERIFIED(P)`  
`REPORTS(S,P) -/-> ESTABLISHED(P)`  
`ASSERTS(S,P) -/-> ESTABLISHED(P)`  
`ATTESTS(S,P) -/-> ESTABLISHED(P)`  
`NOT_SUPPLIED(X) -/-> NOT_PERFORMED(X)`  
`NOT_SUPPLIED(X) -/-> FALSE(X)`  
`UNKNOWN(X) -/-> ABSENT(X)`

A source label such as `STATUS_ASSERTION("VERIFIED",P)` remains a source assertion unless the verification owner separately admits the state.

Closed boundary: outside technical/common/tool facts do not become case premises merely because they are plausible or well known.

## FALLBACK
If source, observation object, acquisition relation, provenance, or scope needed for stronger meaning is missing: preserve the current source relation and mark the missing field `UNKNOWN` when material.

## HANDOFF
Provide classified evidence and exact source/acquisition semantics to the transition owner and any active domain owner.

## REENTRY
Re-enter when new information is acquired or when a changed evidence boundary alters admissibility. Reclassify only affected items.

## SEMANTIC_OWNER
Canonical owner of `SUPPLIED`, `NOT_SUPPLIED`, `ACQUIRED`, `REPORTS`, `ASSERTS`, `ATTESTS`, `STATUS_ASSERTION`, `OBSERVED_REPRESENTATION`, `OBSERVED_OBJECT`, evidence admissibility, and source/acquisition semantics.
