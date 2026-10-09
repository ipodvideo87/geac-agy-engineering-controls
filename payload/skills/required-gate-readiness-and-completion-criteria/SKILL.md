---
name: required-gate-readiness-and-completion-criteria
description: "STOP AND CHECK THE CRITERION: Use this skill whenever a status or conclusion says or implies ready, safe, pass, fail, correct, complete, acceptable, compliant, validated, releasable, or satisfied, especially when it depends on a policy, threshold, definition, requirement, or acceptance rule."
---
# GEAC X1 — Engineering Criteria and Status

## COMPONENT_ID
`CRITERIA_STATUS`

## ROLE
Separate empirical properties from the criteria that map them into operational statuses, requirements, pass/fail, or completion.

## ACTIVATES_WHEN
The task asks or asserts readiness, safety, releaseability, pass/fail, correctness, completeness, mandatory requirements, blockers, or another criterion-dependent status.

## REQUIRES
Criterion content plus source, applicability to exact object/scope/version/time, and established properties to evaluate.

## CONSUMES
Criterion representations, authority/applicability relations, established evidence/properties.

## PRODUCES
Applicable-criterion state, criterion-not-established/failed state, and bounded criterion-dependent status.

## CONSTRAINS
Topic relevance is not criterion applicability. Empirical properties do not define a policy. Unsourced adjectives must not create hidden requirements.

## MAY_ACTIVATE
Evidence/source, transitions, testing, authority, reporting.

## PROHIBITED_TRANSITIONS
`CRITERION_NOT_ESTABLISHED(C) != CRITERION_FAILED(C)`  
`PROPERTY(P) -/-> READY` without an applicable readiness criterion.  
`PASS(test_or_criterion) -/-> CORRECT(system)`  
`COMPLETE(X,dimension_1) -/-> COMPLETE(X,dimension_2)`

If no applicable readiness criterion exists, readiness is `NOT_ESTABLISHED`, not `FAIL` and not an invitation to invent requirements.

Words such as critical, mandatory, required, blocking, essential, release-gating, necessary-for-readiness, or sufficient-for-readiness need an identified governing basis.

## FALLBACK
Preserve established properties and return the requested criterion-dependent state as `NOT_ESTABLISHED` when criterion/applicability is missing.

## HANDOFF
Send bounded criterion/status state to the kernel, authority/action when decisions depend on it, and reporting.

## REENTRY
Re-enter when criterion content, applicability, object version/time, or evaluated evidence changes.

## SEMANTIC_OWNER
Canonical owner of `READY`, `SAFE`, `PASS`, `FAIL`, `CORRECT`, `COMPLETE`, criterion applicability, and criterion-dependent requirement semantics.
