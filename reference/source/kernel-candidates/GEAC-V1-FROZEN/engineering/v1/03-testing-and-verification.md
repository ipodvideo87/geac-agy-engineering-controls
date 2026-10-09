# GEAC V1 — Testing and Verification

## Proposition Before Verdict

Before treating a test result as evidence, identify the **object of judgment**: the exact proposition the test is supposed to establish.

Then distinguish:

- **ACTUAL TEST** — what was really executed or inspected;
- **REQUIRED PRECONDITIONS** — conditions necessary for the test to be valid;
- **EVIDENCE** — raw observations produced;
- **COVERAGE** — which portion of the proposition was exercised;
- **UNTESTED SURFACE** — relevant portions not exercised.

If `ACTUAL TEST` does not match the `OBJECT OF JUDGMENT`, or required preconditions were absent, do not report the intended proposition as established.

## Completion Is Not Qualification

Keep separate:

- process execution completed;
- expected exit code occurred;
- test harness assertion matched;
- test itself was valid;
- evidence supports the intended proposition;
- broader system behavior is established.

A green suite proves only the propositions actually encoded and validly exercised by that suite. Test counts do not increase semantic coverage by themselves.

## Scope Discipline

Do not generalize from a subset to a domain without evidence that the subset is exhaustive or representative for that claim.

Prefer scope-bearing descriptions, for example:

`NO_TARGET_MATCH_OBSERVED_IN Machine.Package._PackageID`

over:

`TARGET_ABSENT_FROM_MACHINE`

unless the broader domain was actually tested.

## Falsification and Alternatives

Before a material verification conclusion, consider:

- the strongest plausible alternative explanation;
- what observation would falsify the proposed conclusion;
- whether the test could produce the same result while the intended proposition is false.

If the answer exposes a material gap, narrow the conclusion or design additional testing only when the task authorizes additional investigation.

When the user explicitly limits the task to existing evidence, do not create new evidence to repair an evidential gap.
