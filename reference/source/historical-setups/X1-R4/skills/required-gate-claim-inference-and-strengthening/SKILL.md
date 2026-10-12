---
name: required-gate-claim-inference-and-strengthening
description: 'STOP AND CHECK THE INFERENCE: Use this skill whenever evidence or prior claims are combined, paraphrased, explained, generalized, strengthened, or used to infer a new proposition, especially mechanism, causality, scope, certainty, probability, provenance, identity, criterion, actor, environment, implementation, or authority.'
---
# GEAC X1 — Engineering Transitions

## COMPONENT_ID
`SEMANTIC_TRANSITIONS`

## ROLE
Permit only transformations whose premises and connecting relationship support the exact bounded target proposition.

## ACTIVATES_WHEN
An item is paraphrased, combined, generalized, specialized, explained, inferred from, or converted into a new claim/state.

## REQUIRES
Classified admissible premises from evidence/source control and any active owner-specific states.

## CONSUMES
`T: {X1...Xn} -> P`, premise states, source relations, scope/time/object qualifiers.

## PRODUCES
`TRANSITION_ACCEPTED(T)` or `TRANSITION_REJECTED(T, missing_relation)` plus bounded derived claim states.

## CONSTRAINS
Preserve actor, predicate, object, scope, time, provenance, result type, criterion relation, identity dimension, and uncertainty. Explanatory detail is itself a claim and needs support.

## MAY_ACTIVATE
Any semantic owner implicated by a controlled relation; especially testing, identity, criteria, authority, and reporting.

## PROHIBITED_TRANSITIONS
`RESULT(R) -/-> MECHANISM(M)`  
`REPORTS(S,P) -/-> P`  
`EXPECTED(P) -/-> ACTUAL(P)`  
`CORRELATION(A,B) -/-> CAUSATION(A,B)`  
`ASSUMPTION(A) -/-> ESTABLISHED(A)`  
`POSSIBLE(P) -/-> PROBABLE(P)`  
`INFERRED(P) -/-> ESTABLISHED(P)` solely because the inference is plausible.

Outcome known + mechanism unknown remains `OUTCOME_KNOWN + MECHANISM_UNKNOWN`.

## FALLBACK
`TRANSITION_REJECTED -> STOP_DEPENDENT_BRANCH -> PRESERVE_PRIOR_STATE`. Independent branches continue.

## HANDOFF
Send accepted/rejected transition state to the kernel, the target semantic owner, and reporting admission.

## REENTRY
Re-evaluate only transitions dependent on new/changed evidence or owner state.

## SEMANTIC_OWNER
Canonical owner of transition validity, derivation relations, semantic-preservation rules, and branch-local rejection behavior.
