# GEAC X1 Experimental Behavioral Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reversible, hash-identified GEAC X1 experimental package that installs a small global `GEMINI.md` kernel plus eight focused Antigravity CLI global Skills and preserves the first behavioral run as an experimental baseline.

**Architecture:** X1 uses `~/.gemini/GEMINI.md` as the always-on task/state/operation and claim-emission kernel. Specialized semantics are split into eight focused global Antigravity CLI skills under `~/.gemini/antigravity-cli/skills/`, matching current CLI documentation. Installation is staged, backed up, verified, and changes `GEMINI.md` last.

**Tech Stack:** Markdown/YAML frontmatter, PowerShell 7-compatible scripts, JSON manifests, Python 3/pytest for package static tests, ZIP distribution.

## Global Constraints

- X1 is an experimental behavioral baseline, not a promotion candidate.
- B0 remains historical Preview-02; X1 never rewrites prior behavioral evidence.
- Design input is a 50/50 synthesis of Google-documented Antigravity/Gemini mechanisms and the task→state→operation/control-graph architecture.
- Observed `agy` behavior is measurement, not a third design input.
- Do not edit installed X1 during a behavioral run; any change creates X1-R1 or later.
- Global Rule `GEMINI.md` must stay below Google's 12,000-character Rule-file limit.
- Use Antigravity CLI global skills in `~/.gemini/antigravity-cli/skills/` with YAML frontmatter.
- Skills are focused semantic owners; `LOAD_GRAPH != CONTROL_GRAPH`.
- Install skills before `GEMINI.md` and verify exact installed hashes.
- Preserve/restore any pre-existing `GEMINI.md` and any X1-managed skill paths.
- Never reconstruct the historical SANITY-001 prompt if exact bytes/text are not available.

---

### Task 1: Package contract tests

**Files:**
- Create: `tests/test_x1_package.py`

**Interfaces:**
- Consumes: approved design spec.
- Produces: executable static contract for required files, kernel size, skill frontmatter/interface fields, semantic ownership, installer/restore safety markers, and prompt-integrity guard.

- [ ] Write tests that fail while package payload does not exist.
- [ ] Run `pytest -q tests/test_x1_package.py` and confirm failure is due to missing X1 payload.

### Task 2: Always-on X1 kernel

**Files:**
- Create: `payload/GEMINI.md`

**Interfaces:**
- Consumes: X1 architecture contract.
- Produces: task classification, canonical state, operation selection, skill routing, claim-emission gate, persistence/re-entry, global invariants.

- [ ] Implement minimal kernel satisfying tests and <12,000 characters.
- [ ] Run tests and preserve any failures for missing skills as expected.

### Task 3: Eight focused semantic-owner skills

**Files:**
- Create: `payload/skills/geac-x1-engineering-evidence.md`
- Create: `payload/skills/geac-x1-engineering-transitions.md`
- Create: `payload/skills/geac-x1-engineering-testing.md`
- Create: `payload/skills/geac-x1-engineering-identity.md`
- Create: `payload/skills/geac-x1-engineering-criteria.md`
- Create: `payload/skills/geac-x1-engineering-authority.md`
- Create: `payload/skills/geac-x1-engineering-history.md`
- Create: `payload/skills/geac-x1-engineering-reporting.md`

**Interfaces:**
- Each skill declares COMPONENT_ID, ROLE, ACTIVATES_WHEN, REQUIRES, CONSUMES, PRODUCES, CONSTRAINS, MAY_ACTIVATE, PROHIBITED_TRANSITIONS, FALLBACK, HANDOFF, REENTRY, SEMANTIC_OWNER.
- Skills consume/produce canonical state, never independent hidden ledgers.

- [ ] Implement each focused skill with explicit activation description and semantic owner.
- [ ] Run package tests and confirm structure/ownership tests pass.

### Task 4: Experiment protocols and micro-regressions

**Files:**
- Create: `experiments/FIRST-RUN-SANITY-001.md`
- Create: `experiments/MICRO-REGRESSIONS.md`
- Create: `experiments/X1-RUN-RECORD-TEMPLATE.md`

**Interfaces:**
- Produces: uncontaminated first-run procedure, micro-test prompts, and run-evidence capture structure.

- [ ] Encode first-run discipline without reconstructing unavailable historical prompt text.
- [ ] Add focused post-baseline micro-regressions.
- [ ] Add run-record template for exact candidate hash, session freshness, prompt source/hash where available, raw response path/hash, and classification.
- [ ] Run tests.

### Task 5: Manifest, verifier, installer, and restore

**Files:**
- Create: `tools/build_manifest.py`
- Create: `Install-GEAC-X1.ps1`
- Create: `Verify-GEAC-X1.ps1`
- Create: `Restore-GEAC-X1.ps1`
- Generate: `X1-PAYLOAD-MANIFEST.json`

**Interfaces:**
- Manifest maps package-relative payload file -> target-relative install path -> SHA-256.
- Installer creates immutable timestamped backup state, stages skills, installs GEMINI last, then verifies.
- Restore removes X1-managed targets and restores exact pre-X1 state from an explicit backup path.

- [ ] Add failing tests for missing scripts/manifest safety properties.
- [ ] Implement manifest builder.
- [ ] Implement verifier.
- [ ] Implement installer with no-overwrite backup, backup-state JSON, skill-first/GEMINI-last order, and post-install verification.
- [ ] Implement restore requiring explicit backup path and backup-state metadata.
- [ ] Generate manifest and run tests.

### Task 6: Documentation and distribution

**Files:**
- Create: `README.md`
- Copy: `docs/2026-08-15-geac-x1-experimental-behavioral-baseline-design.md`
- Copy: `docs/superpowers/plans/2026-08-15-geac-x1-experimental-baseline-implementation.md`
- Generate: `PACKAGE-SHA256.txt`
- Generate: `GEAC_X1_EXPERIMENTAL_BASELINE.zip`

**Interfaces:**
- README provides exact install/verify/restore and first-run sequence.
- Package SHA identifies final ZIP and key payload artifacts.

- [ ] Document current official Antigravity path assumptions as design basis, not behavioral proof.
- [ ] Run full static test suite.
- [ ] Build ZIP deterministically enough for this artifact and compute SHA-256.
- [ ] Inspect archive contents and verify manifest against extracted payload.

### Task 7: Final verification

- [ ] Run `pytest -q` from package root.
- [ ] Verify `GEMINI.md` character count <12,000.
- [ ] Verify exactly eight X1 skill files exist and have unique names/descriptions.
- [ ] Verify every payload hash matches `X1-PAYLOAD-MANIFEST.json`.
- [ ] Extract ZIP into a fresh directory and rerun package tests against extracted contents.
- [ ] Record final ZIP SHA-256 and report any remaining limitation: PowerShell scripts are statically validated here because this build environment does not provide PowerShell; Windows execution remains the first host-side validation step.
