# GEAC X1 — Experimental Behavioral Baseline

**Contract:** `GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE`  
**Status:** **NOT A PROMOTION CANDIDATE**  
**Purpose:** Install the first testable expression of the new GEAC control architecture and learn from real `agy` behavior.

## What X1 changes

X1 presents the existing assurance ideas as an operational architecture:

`TASK -> STATE -> OPERATION -> CLAIM-EMISSION ADMISSION`

The always-on `GEMINI.md` kernel performs task classification, canonical state construction, operation selection, routing, persistence, re-entry, and per-claim admission. Eight focused Skills own specialized semantics for evidence, transitions, testing, identity, criteria, authority, history, and reporting.

## Documented design basis versus behavioral evidence

The physical layout uses current Antigravity CLI documentation as a **documented design basis**:

- global developer context is consulted from `~/.gemini/GEMINI.md`;
- Antigravity CLI global skills are stored under `~/.gemini/antigravity-cli/skills/` as Markdown skills;
- `/skills` can browse loaded local and global Agent Skills;
- Antigravity's Agent Skills documentation describes discovery/activation/execution and recommends focused skills with clear descriptions;
- Gemini prompting guidance recommends clear structure, critical constraints early, decomposition, chaining, and iterative refinement from observed responses.

Those documented mechanisms guide X1's architecture. Their presence/configuration **does not prove** that a particular Skill activates correctly, that a control is applied, or that X1 is behaviorally effective. The X1 runs measure that.

Official references used during the build:

- https://antigravity.google/docs/cli/gcli-migration
- https://antigravity.google/docs/cli/plugins
- https://antigravity.google/docs/cli/reference
- https://antigravity.google/docs/skills
- https://ai.google.dev/gemini-api/docs/prompting-strategies

## Managed install targets

X1 manages exactly nine files:

- `~/.gemini/GEMINI.md`
- eight `geac-x1-engineering-*.md` files under `~/.gemini/antigravity-cli/skills/`

The exact package-to-target mapping and SHA-256 values are in `X1-PAYLOAD-MANIFEST.json`.

## Install on Windows / PowerShell 7

From the extracted X1 package directory:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Install-GEAC-X1.ps1
```

The installer:

1. validates the X1 payload manifest;
2. creates a new timestamped backup under `~/.gemini/geac-backups/X1/`;
3. copies and hashes every pre-existing managed file into that backup;
4. writes `backup-state.json` and a copy of the X1 manifest;
5. installs all eight Skills first;
6. installs `GEMINI.md` last;
7. verifies the installed bytes against the manifest;
8. prints `BACKUP_PATH=...`.

**Save that exact backup path.** The installer refuses to overwrite an existing backup directory and attempts rollback if installation fails after backup state is written.

## Verify installed bytes

```powershell
.\Verify-GEAC-X1.ps1
```

Every managed target should print `OK`, followed by a PASSED line.

## Verify Skill discovery before the behavioral baseline

For the cleanest experiment, launch a temporary fresh `agy` session, run `/skills`, and check whether the eight `geac-x1-engineering-*` skills are listed. Record the observation, then close that session.

This establishes discoverability only. It does not establish automatic activation or correct application.

Then launch another **fresh** `agy` session for the actual first behavioral run.

## First behavioral run

Read:

`experiments/FIRST-RUN-SANITY-001.md`

The first substantive test should be the exact preserved historical SANITY-001 prompt before any diagnostic micro-test. The historical exact prompt is not reconstructed in this package; the protocol deliberately stops rather than substituting a different test if exact recovery is unavailable.

Use `experiments/X1-RUN-RECORD-TEMPLATE.md` to preserve identity and raw evidence.

After the integration baseline is safely recorded, use:

`experiments/MICRO-REGRESSIONS.md`

for focused diagnostic runs.

## Restore exact pre-X1 managed-file state

Use the exact backup path printed during installation:

```powershell
.\Restore-GEAC-X1.ps1 -BackupPath '%USERPROFILE%\.gemini\geac-backups\X1\<timestamp>'
```

Restore verifies backup hashes, removes X1-managed files, restores the files that existed before X1, preserves originally absent files as absent, and restores `GEMINI.md` last.

If a managed file was independently edited after X1 installation, restore fails closed rather than discarding that edit. Use `-Force` only when you explicitly intend to discard such a post-X1 edit.

## Experimental discipline

- Do not edit installed X1 during a run.
- Preserve raw failures as well as successes.
- Rule presence is not behavioral effectiveness.
- Skill discoverability is not Skill activation.
- A correct headline does not sanitize unsupported later prose.
- Any architecture edit after X1 evidence becomes a new revision identity such as `X1-R1`.
