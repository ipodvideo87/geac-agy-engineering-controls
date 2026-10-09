---
name: required-gate-claim-output-validation
description: "STOP AND CHECK THE OUTPUT CLAIM: Use this skill whenever writing, emitting, or reformulating a material case-specific engineering conclusion, explanation, heading, table entry, summary, recommendation, verdict, status statement, completion claim, self-review, or other output claim."
---
# GEAC X1 — Engineering Reporting and Representation

## COMPONENT_ID
`REPORTING_EMISSION`

## ROLE
Preserve the canonical state and surviving transition graph through every material output clause so later prose cannot silently strengthen an earlier bounded result.

## ACTIVATES_WHEN
Any material engineering output is generated, summarized, tabulated, recommended, certified, self-reviewed, or restated.

## REQUIRES
Current canonical state, admissible evidence, accepted/rejected transitions, active semantic-owner states, relevant history/contradictions.

## CONSUMES
Candidate clause plus its support relation and exact qualifiers.

## PRODUCES
`EMIT`, `NARROW`, or `REJECT` decision and final bounded wording.

## CONSTRAINS
For every material case-specific clause: classify clause type; bind support; resolve controlled states through owners; preserve source/scope/time/identity/provenance/criterion/authority limits; reject/narrow wording that requires a rejected or absent transition.

Apply equally to headings, bullets, tables, explanations, summaries, recommendations, parentheticals, next steps, and final verdicts.

## MAY_ACTIVATE
Any semantic owner whose state appears in the candidate clause.

## PROHIBITED_TRANSITIONS
`CORRECT_HEADLINE -/-> SUPPORTING_PROSE_VALID`  
`SELF_REVIEW -/-> INDEPENDENT_CERTIFICATION`  
`SOURCE_ASSERTION -/-> CASE_FACT` without an admitted relation.  
`HYPOTHETICAL -/-> CASE_FACT`  
`GENERAL_TECHNICAL_PROPOSITION -/-> CASE_PREMISE` under a closed boundary without permission.

A correct verdict does not sanitize unsupported support. A later summary may not upgrade a distinction preserved earlier.

## FALLBACK
If polished wording requires unsupported detail: `NARROW` to the strongest supported relation or `REJECT` the clause. Prefer less detail over semantic completion.

## HANDOFF
Return only admitted bounded output to the response surface. Do not create a separate self-certifying ledger.

## REENTRY
Every new material candidate clause re-enters emission admission. New evidence first changes canonical state through its owner, then output may be reconsidered.

## SEMANTIC_OWNER
Canonical owner of claim-emission admission, output distinction persistence, representation-versus-referent reporting, and self-review limitations.
