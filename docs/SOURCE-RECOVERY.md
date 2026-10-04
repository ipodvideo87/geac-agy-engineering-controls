# GEAC source recovery and completeness audit

Audit date: 2026-10-03. This records what was recovered, what belongs in the installable package, and what remains missing. Historical files are kept separate from the current installer payload.

## Recovered implementation lineage

| Stage | Recovered source | What it contains | Packaging treatment |
|---|---|---|---|
| V1 / V1.1 | `GEAC-2026-08-14-V1.zip`, `GEAC_V1_1_Candidate_D2.zip` | Earlier candidate architecture and policy drafts | V1 ZIP is retained in the local recovery copy but omitted from this public copy because its README embeds a local Windows user path; V1.1 is preserved under `reference/source/archives/` |
| E2 | `GEAC_E2_PREVIEW_01.zip`, `GEAC_E2_PREVIEW_02.zip`, `GEAC_E2_IMPORT_PROBE_01.zip` | Later previews and an import probe; the probe has its own install/restore PowerShell scripts | Preserved under `reference/source/archives/`; not the R1 release |
| X1 | `GEAC_X1_EXPERIMENTAL_BASELINE.zip` and its extracted source tree | Always-on `GEMINI.md` kernel, eight skills, PowerShell install/restore/verify, Python manifest builder and package-test source, manifests, design basis, and experiment protocol | Extracted source is preserved under `reference/source/x1-original/`; a local-path example in its README is normalized here. The exact ZIP remains in the local recovery copy and is omitted from this public copy for the same privacy reason. Original SHA-256 is recorded in `SOURCE-BASIS.json` |
| X1-R1 | `GEAC_X1_R1_IDENTITY_PATCH.zip` | Python identity/provenance patcher, its test source, change note, README, and output hash | Exact ZIP and extracted source are preserved; only the identity skill content is used in the current plugin |
| R3 discovery | `Update-Gemini-Skill-Discovery.ps1` and `Update-Gemini-Skill-Discovery-v2.ps1` | Renames the eight skills and rewrites discovery descriptions plus references in `GEMINI.md` | Both exact scripts are preserved under `reference/source/r3-skill-discovery/`; neither is run by the installer |

The source X1 tree contains the eight skill files and the Python files `tools/build_manifest.py` and `tests/test_x1_package.py`. The R1 archive contains `Apply-GEAC-X1-R1.py` and `test_apply_geac_x1_r1.py`. These source files are represented in the reference tree. Test files are preserved as source; they were not run for this packaging task.

## What the R3 scripts do

The two R3 PowerShell scripts do **not** force all eight skills on. They rename skills and broaden their frontmatter descriptions so the agent is more likely to select them during its relevance-based discovery. The v2 script is later than v1. It writes new description values as unquoted YAML plain scalars, including values containing `: `; the continuity record says that malformed descriptions caused skills to disappear from discovery. The current package applies the exact eight v2 names and descriptions, with descriptions safely quoted as YAML strings. Keep the original scripts as historical references and do not run them as the auto-on mechanism.

## The missing forced-on source

No historical source for the remembered all-eight-skills auto-on script or hook was found in:

- the GEAC and Antigravity ZIPs examined in Downloads;
- the two R3 PowerShell scripts and the R1 Python patch source;
- the current `.gemini` GEAC plugin files, apart from the preview hook authored during this packaging work;
- the `.codex-old` named files, session JSONL records, or thread-history records;
- the searched ChatGPT Library items or either linked XMemo account.

The Aug 23 Library continuity document describes a later PreInvocation forced-gate path (FG-v1) and why it was introduced, but it does not provide the original hook source. The current preview's earlier reminder hook was authored during packaging work and was not the missing historical implementation.

This package therefore includes a **reconstruction**, not a recovered original: an enabled `PreInvocation` hook unconditionally injects the full text of all eight `SKILL.md` files into every model invocation. The source generator is `tools/build_auto_state_payload.py`; the runtime emitters are `plugin/scripts/geac-preinvocation.ps1` and `.sh`. This removes dependence on the skill relevance selector for loading the instructions. It cannot guarantee that the model follows them.

Google's current documentation describes the default skill flow as discovery followed by relevance-based activation, and documents a `PreInvocation` hook's ability to inject a transient system message before each model call: [Agent skills](https://antigravity.google/docs/skills), [Hooks](https://antigravity.google/docs/hooks/). The reconstruction uses that documented interface; it is not evidence that the old FG-v1 implementation behaved the same way.

## Library and XMemo findings

- The ChatGPT Library contains the Aug 23 `Antigravity_IDE_Setup_Deep_Continuity_Context` note, August 16 research ZIP revisions, and the X1/R1/E2 artifacts. The continuity note contains the long motivation and reports an earlier forced-gate path. It is the source used for [`RATIONALE.md`](RATIONALE.md).
- The August 16 research ZIP contains useful skill-discovery and hook documentation, but also an ESP32-IDE candidate trace with unrelated project identifiers, hashes, and paths. The raw trace is intentionally not copied into this public package; do not publish it unchanged.
- Searches of both connected XMemo accounts found no GEAC/AGY-specific project or memory containing the promised long rationale or missing hook source. XMemo had generic engineering rules only. The public rationale is therefore attributed to the Library continuity note, not XMemo.
- `Release.7z` in Downloads was inspected and contains an unrelated XToolbox Windows application.
- The loose `Apply-GEAC-X1-R1.py` in Downloads matches the R1 patch source; the two R3 scripts are the only loose GEAC-related PowerShell discovery scripts there. X1 and E2 archives contain their own install/restore/verify scripts as shown above.

## Known missing behavioral evidence

The X1 package labels itself an experimental baseline, not a promotion candidate. Its run protocol references the exact SANITY-001 prompt and the R1 patch note names a targeted acceptance replay, but the exact historical prompt, R1 fixture, and raw result were not recovered. Do not claim a measured behavioral improvement until those records are supplied or a new, clearly labeled evaluation is performed.

