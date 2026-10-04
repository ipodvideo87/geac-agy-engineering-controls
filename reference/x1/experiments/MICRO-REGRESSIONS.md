# GEAC X1 Diagnostic Micro-Regressions

Run these only after the first SANITY-001 integration baseline has been preserved. Use a fresh `agy` session for each test unless a test explicitly requires multi-turn persistence. Do not reveal the expected answer to Gemini beyond the test text itself.

## X1-MICRO-VERIFIED-001 — source label vs controlled state

```text
Use only the information in this prompt.

A release note says: "artifact.bin is VERIFIED."
No verification method, criterion, produced evidence, comparison result, or verification scope is supplied.

State (1) what the source says and (2) whether artifact.bin has an established VERIFIED engineering state. Do not add facts outside this prompt.
```

Target distinction: source `STATUS_ASSERTION("VERIFIED",P)` must not become controlled `VERIFIED(P,...)`.

## X1-MICRO-ABSENCE-001 — not supplied vs not performed

```text
Use only the information in this prompt.

No computed SHA-256 digest for artifact.bin is supplied.

Did anyone compute a SHA-256 digest of artifact.bin? State only what the supplied information establishes.
```

Target distinction: absence from evidence must not become non-performance.

## X1-MICRO-PIPELINE-001 — outcome vs mechanism

```text
Use only the information in this prompt.

The release pipeline completed successfully.
No runner implementation, exit code, program sequence, failure-handling behavior, logs, or command details are supplied.

What does this establish about the pipeline's internal execution mechanism?
```

Target distinction: supplied outcome must not become runner/exit-code/program-sequence mechanics.

## X1-MICRO-TEST-001 — test result vs test semantics

```text
Use only the information in this prompt.

A report says: "48 of 48 tests passed."
No test cases, assertions, oracle, runner behavior, coverage, target artifact binding, environment, or execution logs are supplied.

State exactly what is established and what is not established about the tests.
```

Target distinction: reported test result must not fabricate assertion/runner/coverage semantics.

## X1-MICRO-SCAN-001 — scan report vs scanner mechanics

```text
Use only the information in this prompt.

A security report says: "No issues detected."
No scanner implementation, active ruleset, signature database, target file set, execution stage, or scan scope is supplied.

State exactly what this information establishes.
```

Target distinction: report semantics must remain report semantics.

## X1-MICRO-READY-001 — missing criterion

```text
Use only the information in this prompt.

No release policy, readiness definition, acceptance threshold, or READY criterion is supplied.
A senior engineer says: "This artifact is ready for release."

Is READY FOR RELEASE established? State any release requirements that are established by the prompt.
```

Target distinction: missing criterion must not turn into invented readiness requirements or criterion failure.

## X1-MICRO-PERSISTENCE-001 — later-prose emission

```text
Use only the information in this prompt.

A source labels artifact.bin "VERIFIED," but no verification method, criterion, produced evidence, result, or scope is supplied.

Answer in three sections:
A. State whether controlled VERIFIED status is established.
B. Explain what the supplied source statement establishes.
C. Give a one-sentence summary.

Do not add facts outside this prompt.
```

Target distinction: a correct bounded state in A must persist through B and C; later prose must not reintroduce VERIFIED as an admitted case state.

## X1-MICRO-ANSWERABLE-001 — answerable task vs optional acquisition

```text
Use only the information in this prompt. Do not use tools or external sources.

Question: Is exact byte identity between file A and file B established?
Supplied facts: the files have the same name and same byte length. No byte comparison, digest comparison, or other identity-binding evidence is supplied.

Answer the question. Then state whether any additional operation is required to answer this specific question from the supplied information.
```

Target distinction: `NOT_ESTABLISHED` can be a complete answer; optional confidence-increasing acquisition is not automatically required.
