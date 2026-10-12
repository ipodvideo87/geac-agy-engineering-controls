---
name: required-gate-historical-evidence-preservation
description: 'STOP AND CHECK HISTORY: Use this skill whenever evidence or engineering state changes over time, or later success, failure, contradiction, remediation, replacement, revision, reconstruction, or new evidence could be interpreted as changing, erasing, or rewriting an earlier record or state.'
---
# GEAC X1 — Engineering History and Contradictions

## COMPONENT_ID
`HISTORY_CONTRADICTION`

## ROLE
Maintain append-only meaning across time: later evidence may change current conclusions but must not silently rewrite prior states or convert remediation into historical cause.

## ACTIVATES_WHEN
A failure is followed by success, evidence changes, contradiction appears, remediation occurs, a record is reconstructed, or current and prior states differ.

## REQUIRES
Time-bound evidence/claim states and the basis available at each relevant time.

## CONSUMES
Historical/current claim states, contradictions, remediation evidence, reconstructed representations.

## PRODUCES
`HISTORICAL_STATE`, unresolved/resolved contradiction state, remediation state, reconstruction classification.

## CONSTRAINS
Preserve earlier failure, invalid test, unsupported claim, crossed stop condition, or unauthorized action even after later improvement. Resolution requires evidence that discriminates the conflict for a specified proposition/purpose.

## MAY_ACTIVATE
Evidence/source, transitions, identity/time, authority, reporting.

## PROHIBITED_TRANSITIONS
`TRUE_NOW(P) -/-> TRUE_EARLIER(P)`  
`AVAILABLE_NOW(E) -/-> AVAILABLE_EARLIER(E)`  
`REPAIRED_NOW(S) -/-> NEVER_FAILED_EARLIER(S)`  
`LATER_SUCCESS -/-> EARLIER_ACTION_AUTHORIZED`  
`RECONSTRUCTED_RECORD(R) -/-> CONTEMPORANEOUS_RECORD(R)`

A representation/ledger/status label does not create the event/state it purports to record.

## FALLBACK
If new evidence does not discriminate a historical contradiction, keep the contradiction explicit while reporting any separately supportable current state.

## HANDOFF
Send time-bound state and required historical qualifiers to transition/identity/reporting controls.

## REENTRY
Re-enter whenever new evidence changes the current best conclusion or purports to resolve a contradiction.

## SEMANTIC_OWNER
Canonical owner of historical-state preservation, contradiction resolution, remediation-versus-cause separation, and reconstructed-record semantics.
