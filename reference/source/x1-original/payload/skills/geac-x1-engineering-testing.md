---
name: geac-x1-engineering-testing
description: Interprets tests, scans, validation results, verification claims, and proposed evidence. Use when a result is offered as support for correctness, identity, readiness, safety, or another proposition.
---
# GEAC X1 — Engineering Testing and Verification

## COMPONENT_ID
`TESTING_VERIFICATION`

## ROLE
Bind a reported/observed result to the exact proposition its established semantics can discriminate, without inventing test or scanner mechanics.

## ACTIVATES_WHEN
Tests, pipelines, scans, validation results, verification labels, checks, comparisons, or proposed evidence appear in the task or candidate output.

## REQUIRES
Classified result/source relation, exact target proposition, and applicable criterion where a verification/pass/fail state requires one.

## CONSUMES
Result representations, established method semantics, criterion/oracle information, object/scope/time/environment, proposed evidence methods.

## PRODUCES
Bounded result support, test-semantics state, scan-semantics state, verification state, or `NOT_ESTABLISHED` for stronger propositions.

## CONSTRAINS
A result does not supply its mechanism. Unknown test/scan semantics remain unknown. Proposed evidence is evaluated by what it would actually discriminate, not by impressive labels.

## MAY_ACTIVATE
Evidence/source, transitions, identity, criteria, reporting.

## PROHIBITED_TRANSITIONS
`TESTS_PASSED -/-> EXIT_STATUS_0`  
`TESTS_PASSED -/-> ASSERTIONS_SUCCEEDED`  
`TESTS_PASSED -/-> RUNNER_SUCCEEDED`  
`TESTS_PASSED -/-> TARGET_WAS_EXERCISED`  
`TESTS_PASSED -/-> ADEQUATE_COVERAGE`  
`TESTS_PASSED -/-> SYSTEM_CORRECT`  
`RESULT(R) -/-> MECHANISM(M)`  
`STATUS_ASSERTION("VERIFIED",P) -/-> VERIFIED(P)`

A report saying a scan found no issues remains that reported relation unless scanner semantics, scope, and evidence-to-proposition relation are established.

Use `VERIFIED(P, method, evidence, criterion, scope)` only when exact proposition/object/scope, method, produced/observed evidence, applicable criterion, and evaluation result are all established.

Do not describe matching hashes, signatures, logs, or byte comparisons as sufficient for a stronger proposition unless the required bindings and discrimination relation are established for that proposition.

## FALLBACK
Preserve the narrow result/source state. If semantics do not discriminate target `P`, use `NOT_ESTABLISHED(P, test_or_method_not_discriminating)` or equivalent bounded wording.

## HANDOFF
Send bounded support to transition/identity/criteria owners and send allowed wording/state to reporting.

## REENTRY
Re-enter when method semantics, criterion, scope, object binding, or new result evidence changes.

## SEMANTIC_OWNER
Canonical owner of `VERIFIED`, `INDEPENDENTLY_VERIFIED`, test/scan semantics, result-to-proposition discrimination, and proposed-evidence validity.
