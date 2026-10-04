# GEAC X1 — Experimental Behavioral Baseline Design

**Date:** 2026-08-15  
**Status:** APPROVED DESIGN / NOT A PROMOTION CANDIDATE  
**Purpose:** First installed baseline of the new GEAC control architecture. X1 exists to generate behavioral evidence from real Antigravity (`agy`) runs and to drive evidence-based revisions (`X1-R1`, `X1-R2`, ...).

## 1. Design Intent

X1 is a 50/50 synthesis:

- **50% Google-documented Antigravity/Gemini operating model**: persistent global instructions, focused selectively activated components/skills, progressive disclosure, decomposition, staged reasoning, and iterative refinement from observed model behavior.
- **50% our control architecture**: explicit component relationships, single semantic ownership, task → state → operation control, shared controlled-state vocabulary, state persistence, claim generation as an operation, per-claim admission, and re-evaluation after new evidence.

These two design inputs form **100% of the intended X1 behavior**.

Observed `agy` behavior is not a third design input. It is the measurement used to compare intended behavior with actual behavior and to justify later revisions.

## 2. Experimental Status

X1 is intentionally a learning build.

### X1 is

- an installed experimental baseline;
- coherent enough to test;
- precise enough that behavioral deviations can be localized;
- reversible;
- byte-identifiable and hash-manifested;
- frozen during each behavioral run.

### X1 is not

- production-ready;
- promoted;
- certified;
- expected to pass every historical regression;
- permission to rewrite failure history after later improvement.

## 3. Baseline Relationship

- **B0** = preserved historical Preview-02 behavioral baseline and SANITY-001 evidence.
- **X1** = first installed baseline of the new architecture.
- **X1-Rn** = later revisions justified by evidence obtained from prior X1 runs and independently demonstrated static defects.

Do not retroactively modify X1 after a run. A change creates a new revision identity.

## 4. Physical Architecture

### 4.1 Always-on kernel

`~/.gemini/GEMINI.md`

Responsibilities:

- establish X1 identity/status;
- define global non-negotiable invariants;
- classify the active task;
- construct and maintain canonical control state;
- route to applicable specialized control components;
- enforce component ownership/precedence;
- map state to permitted operations;
- apply claim-emission admission;
- re-evaluate affected state after new evidence;
- stop when the active task is answerable unless another operation is actually required.

The kernel is intentionally small. It must not become the entire engineering textbook.

### 4.2 Specialized engineering components

Primary X1 components:

1. `engineering-evidence`
2. `engineering-transitions`
3. `engineering-testing`
4. `engineering-identity`
5. `engineering-criteria`
6. `engineering-authority`
7. `engineering-history`
8. `engineering-reporting`

Preferred physical mechanism for X1: Antigravity native Skills under the global Antigravity CLI skill location, with clear applicability descriptions and focused responsibilities.

Each component is a cooperating control component rather than a detached document.

## 5. Component Interface Contract

Every specialized component must declare:

- `COMPONENT_ID`
- `ROLE`
- `ACTIVATES_WHEN`
- `REQUIRES`
- `CONSUMES`
- `PRODUCES`
- `CONSTRAINS`
- `MAY_ACTIVATE`
- `PROHIBITED_TRANSITIONS`
- `FALLBACK`
- `HANDOFF`
- `REENTRY`
- `SEMANTIC_OWNER`

### 5.1 Relationship vocabulary

Components may relate through explicit control-graph edges such as:

- `REQUIRES`
- `PRECEDES`
- `CONSTRAINS`
- `REFINES`
- `MAY_ACTIVATE`
- `PRODUCES_FOR`
- `CONSUMES_FROM`
- `HANDOFF_TO`
- `MAY_REENTER`
- `SHARES_VOCABULARY_WITH`

### 5.2 Load graph is not the control graph

Physical loading/import relationships and semantic control relationships are separate.

`LOAD_GRAPH != CONTROL_GRAPH`

The design must not require circular file imports merely because semantic control can re-enter or loop.

## 6. Single Semantic Ownership

Every consequential controlled concept has one canonical semantic owner.

Examples:

- `VERIFIED` → verification/testing semantics owner
- `AUTHORIZED` → authority owner
- `SAME_ARTIFACT` → identity owner
- `READY` → criteria/status owner
- `SUPPLIED` → evidence/source owner

Other components may consume, route, constrain, or specialize an owned state. They may not silently redefine it.

## 7. Task → State → Operation Controller

### 7.1 Task classification

The kernel first identifies exact task object(s) and active domains.

Example active domains:

- evidence/source
- identity/provenance
- testing/verification
- criteria/status
- authority/action
- history/contradiction
- reporting/emission

### 7.2 Canonical state model

X1 uses explicit states instead of forcing unsupported propositions into booleans.

Core state values:

- `YES`
- `NO`
- `NOT_ESTABLISHED`
- `NOT_APPLICABLE`
- `CONFLICT`

Rule:

`ABSENCE_OF_SUPPORT != NO`

A negative state requires support for the negative proposition. Otherwise preserve `NOT_ESTABLISHED`.

### 7.3 State persistence

Once constructed, controlled state persists across:

- paragraphs;
- headings;
- bullets;
- tables;
- summaries;
- recommendations;
- next steps;
- final verdicts.

State may change only because valid new evidence or a valid accepted transition justifies re-evaluation.

### 7.4 Operation matrix

The current state maps to behavior.

Examples:

- `TEST_SEMANTICS = NOT_ESTABLISHED` → preserve supplied result wording; prohibit invented runner/assertion/coverage mechanics.
- `READY_CRITERION = NOT_ESTABLISHED` → READY remains not established; prohibit invented readiness requirements.
- `PIPELINE_MECHANISM = NOT_ESTABLISHED` → preserve supplied pipeline outcome; prohibit invented internal execution mechanics.
- `TASK_ANSWERABLE = YES` and no required additional operation → report and stop; do not acquire optional evidence merely for confidence.

## 8. Claim Generation Is an Operation

Every material model-generated clause passes through a claim-emission admission path.

### 8.1 Claim-emission path

1. Construct candidate claim.
2. Classify clause type.
3. Identify active semantic owner(s).
4. Bind supporting evidence/accepted transitions.
5. Resolve controlled vocabulary.
6. Consult canonical current state.
7. Determine whether candidate requires a stronger state/relationship.
8. Validate transition.
9. `EMIT`, `NARROW`, or `REJECT`.

No heading, table, bullet, explanation, recommendation, parenthetical, summary, or verdict bypasses this path.

### 8.2 Historical target example

State:

`STAGED_ARTIFACT_VERIFIED = NOT_ESTABLISHED`

Candidate claim:

`What is verified: ...`

If no accepted transition establishes the controlled `VERIFIED` state, the candidate must be rejected or narrowed to the actual source relation, e.g.:

`The supplied information states ...`

## 9. Re-evaluation Loop

When an authorized/required operation produces new information:

1. classify the new information as evidence;
2. preserve acquisition/source/provenance semantics;
3. identify affected controlled states;
4. re-run only affected transitions/components;
5. preserve historical prior states and contradictions;
6. update downstream operation and emission decisions.

Later success does not erase earlier failure or invalid reasoning.

## 10. Core Global Invariants

X1 always preserves:

1. no fabricated evidence, identity, provenance, authority, credentials, results, or history;
2. missing evidence remains missing;
3. source assertion is not external observation or verification;
4. result is not mechanism;
5. expected/intended is not actual;
6. authorization is not created by usefulness, harmlessness, reversibility, read-only status, technical possibility, convenience, confidence, or seniority;
7. unsupported transitions stop dependent branches while preserving independent branches;
8. method/rule compliance is not empirical proof;
9. later success does not rewrite earlier history;
10. controlled states must satisfy their semantic admission rules before being emitted or used as decision predicates.

## 11. X1 Testing Strategy

### 11.1 First run — integration baseline

The first X1 behavioral run must use the preserved **exact SANITY-001 prompt** in a fresh `agy` session before diagnostic micro-probes.

Purpose:

- obtain an uncontaminated B0 ↔ X1 behavioral comparison;
- observe whether the new presentation/control architecture changes the historical failure pattern.

Preserve the raw response unchanged.

### 11.2 Micro-regressions

After the first SANITY-001 run, use fresh sessions to isolate specific control behaviors:

- source label `VERIFIED` vs controlled `VERIFIED` state;
- `NOT_SUPPLIED` vs `NOT_PERFORMED`;
- pipeline outcome vs invented mechanism;
- test result vs invented test semantics;
- scan report vs invented scanner mechanics;
- missing READY criterion vs invented requirements;
- state persistence across later prose;
- answerable task vs unnecessary acquisition/action.

### 11.3 Historical regression suite

Historical HF families remain append-only behavioral evidence and become later regression coverage. A later pass does not rewrite an earlier failing run.

## 12. Run Discipline

For every installed revision:

1. build candidate in staging;
2. static-check file structure, metadata, references, and size limits;
3. generate SHA-256 manifest;
4. freeze exact candidate bytes;
5. back up current installation;
6. install candidate;
7. verify installed bytes against manifest;
8. start a fresh `agy` session;
9. run the exact selected test;
10. preserve raw response;
11. classify expected vs observed control behavior;
12. end the run before editing candidate source;
13. any change creates a new revision.

Never edit the installed candidate during an active test run.

## 13. Reversibility and Safety

The X1 package must include:

- timestamped backup of current `GEMINI.md` and any X1-managed component paths;
- exact manifest of installed X1 bytes;
- verifier script;
- restore script;
- explicit refusal to overwrite historical backups;
- installation of `GEMINI.md` last so the bootstrap changes only after dependencies are staged.

## 14. What X1 Is Intended to Teach Us

X1 is successful as an experiment if it gives discriminating evidence about:

- global kernel effectiveness;
- component activation;
- semantic ownership;
- routing/composition;
- state construction;
- state persistence;
- state → operation mapping;
- claim-emission admission;
- re-entry after new evidence;
- interaction between native Antigravity component mechanisms and our control architecture.

X1 does **not** need to pass every test to be a successful experiment.

## 15. Revision Policy

`X1-R1` may be created only when a change is justified by:

- preserved X1 behavioral evidence; or
- an independently demonstrable static defect in X1.

Do not revise based only on speculation about hidden model internals.

For each revision, record:

- observed defect;
- exact evidence;
- hypothesized architectural break;
- changed control surface;
- expected behavioral delta;
- test that will discriminate whether the change helped.

## 16. Explicit Non-Goals for X1

X1 will not initially attempt to:

- promote the architecture;
- claim production readiness;
- solve every known GEAC semantic gap simultaneously;
- infer hidden Gemini mechanisms from behavior alone;
- treat native Skills as behaviorally effective merely because they are configured;
- treat rule presence as rule application;
- treat one successful run as general effectiveness.

## 17. First Build Scope

The first X1 package should contain only what is required to test this architecture:

- X1 `GEMINI.md` kernel/controller;
- eight focused engineering Skills;
- manifest with SHA-256 digests;
- README / experiment identity;
- reversible PowerShell installer;
- restore script;
- installed-byte verifier;
- preserved SANITY-001 first-run protocol;
- micro-regression prompt set for follow-up runs.

No promotion tooling is required in X1.

---

# Design Self-Review

**Placeholder scan:** No TBD/TODO placeholders.  
**Internal consistency:** X1 is consistently defined as an experimental baseline; run evidence drives revisions; physical load mechanism is separated from semantic control graph.  
**Scope:** Focused on the first installable learning architecture, not full ECP or production promotion.  
**Ambiguity:** X1 first run is explicitly SANITY-001; micro-tests follow afterward; edits during a run are prohibited; revision identity is explicit.
