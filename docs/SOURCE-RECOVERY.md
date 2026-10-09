# GEAC source recovery and completeness audit

Audit date: 2026-10-09. This records what was recovered, what belongs in the installable package, and what remains missing. Historical files are kept separate from the current installer payload.

## Recovered implementation lineage

| Stage | Recovered source | What it contains | Packaging treatment |
|---|---|---|---|
| V1 / V1.1 | `GEAC-2026-08-14-V1.zip`, `GEAC_V1_1_Candidate_D2.zip` | Earlier candidate architecture and policy drafts | V1 ZIP is retained in the local recovery copy but omitted from this public copy because its README embeds a local Windows user path; V1.1 is preserved under `reference/source/archives/` |
| E2 | `GEAC_E2_PREVIEW_01.zip`, `GEAC_E2_PREVIEW_02.zip`, `GEAC_E2_IMPORT_PROBE_01.zip` | Later previews and an import probe; the probe has its own install/restore PowerShell scripts | Preserved under `reference/source/archives/`; not the R1 release |
| X1 | `GEAC_X1_EXPERIMENTAL_BASELINE.zip` and its extracted source tree | Experimental `GEMINI.md` kernel, eight skills, PowerShell install/restore/verify, Python manifest builder and package-test source, manifests, design basis, and experiment protocol | Historical source is preserved under `reference/source/x1-original/`. The kernel explicitly says it is not a promotion candidate and is excluded from the active installer. A copy from the prior plugin preview is archived under `reference/source/legacy-plugin-preview/`. The exact ZIP remains in the local recovery copy; original SHA-256 is recorded in `SOURCE-BASIS.json` |
| X1-R1 | `GEAC_X1_R1_IDENTITY_PATCH.zip` | Python identity/provenance patcher, its test source, change note, README, and output hash | Exact ZIP is preserved under `reference/source/archives/`; the X1-R1 identity/provenance change is incorporated into the standalone skill payload |
| R3 discovery | `Update-Gemini-Skill-Discovery.ps1` and `Update-Gemini-Skill-Discovery-v2.ps1` | Renames the eight skills and rewrites discovery descriptions plus references in `GEMINI.md` | Both exact scripts are preserved under `reference/source/r3-skill-discovery/`; neither is run by the installer |
| FG-v1 hook | Shared ChatGPT conversation “Gemini WSL Investigation” | Transcript includes the FG-v1 PowerShell source, its global `PreInvocation` registration, and the eight `required-gate-*` names | Script text is preserved under `reference/source/historical-hooks/` and installed/enabled globally by the standalone installer |

The source X1 tree contains the eight skill files and the Python files `tools/build_manifest.py` and `tests/test_x1_package.py`. The preserved R1 archive contains `Apply-GEAC-X1-R1.py` and `test_apply_geac_x1_r1.py`; the identity/provenance change is incorporated into the active skill. Test files are preserved inside the source archives; they were not run for this packaging task.

## Revision path to the latest recovered standalone setup

This sequence records which earlier changes flow into the installable setup and which later-looking material remained exploratory. “Latest” here means the latest recoverable standalone skills-and-hooks configuration; the conversation does not finalize a global kernel or a plugin release.

| Revision or evidence | Change as the work progressed | Current package treatment |
|---|---|---|
| Frozen GEAC V1 reference | Established an earlier engineering-contract baseline. | Its original ZIP remains in Downloads and is omitted from this release because its README embeds a local Windows user path. Its `GEMINI.md` was not selected for this installer. |
| V1.1 D1/D2 and E2 previews | Explored later control boundaries and packaging options. | D2 and E2 archives are included as previews; D1 remains in the local recovery library. None is promoted into the standalone setup. |
| X1 experimental baseline | Reworked the control set into eight engineering skills and a global `GEMINI.md`. | The skills supply the base content. The kernel is explicitly marked “NOT A PROMOTION CANDIDATE” and is not installed. |
| X1-R1 identity/provenance revision | Added explicit rules against inferring a copy, transfer, lineage, generation, or acquisition event from metadata alone. | Incorporated into `required-gate-artifact-identity-and-provenance`. |
| R3 v1, then R3 v2 skill discovery wording | Renamed the skills and broadened their descriptions for relevance-based discovery; v2 is the latest recovered wording. | Uses all eight R3 v2 descriptions, safely quoted in YAML. The package adds the shared `required-gate-` name prefix needed by FG-v1. |
| Transcript-recovered FG-v1 hook | Switched the eight skills from relevance selection to mechanical full-body injection at `PreInvocation`. | Installed and enabled. It scans for the shared prefix and injects every matching skill on each model invocation. |
| Separate R2 claim-admission hook | The full conversation export contains the 36-line source and a later exact configuration. The configuration corrects an earlier five-event description: only `PreInvocation` has a handler; the other event fields are `null`. | Exact script recovered as 1,317 bytes and verified against transcript SHA-256 `927f307b30a56a33f88cc7fb23d2651a5047a16155e82ddce728112fe5d70b6d`; installed as a separate `PreInvocation` hook. |
| Historical profile `GEMINI.md` fingerprint | The conversation's Aug 18 profile census records `~/.gemini/GEMINI.md` present at 9,544 bytes, SHA-256 `96231f08f168d877912e2503b4059026dda34e2fb00512c20c096d34cfa50cdf`. An X1-R4 receipt is timestamped to the same minute as the file inventory, but the transcript does not explicitly connect that receipt to this hash. | Exact bytes were not recovered. This differs from the archived X1 kernel (9,407 bytes, SHA-256 `4561400a6215fc8ebc3f003185269b00ebb0b0eacba81c97529195051276087e`). The fingerprint is documented in `reference/source/kernel-candidates/README.md`; no substitute kernel is installed. File presence does not prove runtime loading or adherence. |
| Later CLI/plugin research | Considered plugin composition, bootstrap ownership, hook ordering, authorization, telemetry, agents, and context accounting. The conversation labels this a research architecture and leaves the bootstrap owner unresolved. | These proposals are documented in `docs/ARCHITECTURE-IDEAS.md`; they are not presented as completed installer features. No plugin or global `GEMINI.md` kernel is installed. |

This ledger is a change-coverage summary, not a verbatim transcript. It distinguishes adopted changes from proposals so the package does not silently turn an experiment into a release decision.

## What the R3 scripts do

The two R3 PowerShell scripts do **not** force all eight skills on. They rename skills and broaden their frontmatter descriptions so the agent is more likely to select them during its relevance-based discovery. The v2 script is later than v1. It writes new description values as unquoted YAML plain scalars, including values containing `: `; the continuity record says that malformed descriptions caused skills to disappear from discovery. The current package uses the eight R3 v2 descriptions, safely quoted as YAML strings, and adds the `required-gate-` prefix to each canonical name for FG-v1 compatibility. Keep the original scripts as historical references and do not run them as the auto-on mechanism.

## Recovered standalone forced-gate hook

A previously unexamined shared ChatGPT conversation contains the source text for the final FG-v1 revision of `geac-required-gate.ps1`. This corrects the earlier audit: the FG-v1 implementation is now transcript-recovered, although its original on-disk bytes were not recovered for a hash comparison. The recovered script is kept outside the current installer payload at [`reference/source/historical-hooks/geac-required-gate.fg-v1.ps1`](../reference/source/historical-hooks/geac-required-gate.fg-v1.ps1).

The conversation records this standalone global skills-and-hooks setup and a global `GEMINI.md` present in that historical profile. The export supplies the active file's byte count and SHA-256 but not its contents. Elsewhere the bootstrap owner is explicitly unresolved, so the current package cannot establish that this was the final promoted kernel or recreate it byte-for-byte.

- Hook registry: `~/.gemini/config/hooks.json`.
- Hook script: `~/.gemini/config/hooks/geac-required-gate.ps1`.
- Skill root: `~/.gemini/antigravity-cli/skills/<skill-folder>/SKILL.md`.
- Hook entry: `geac-required-gate`, enabled, with a `PreInvocation` command using `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` and a 10-second timeout.
- The hook was separate from `geac-x1-r2-claim-admission`, another enabled global hook for claim and lifecycle controls. The auto-load mechanism itself did not require a plugin.

The exact `geac-x1-r2-claim-admission.ps1` source is preserved at [`reference/source/historical-hooks/geac-x1-r2-claim-admission.ps1`](../reference/source/historical-hooks/geac-x1-r2-claim-admission.ps1). Extracting its numbered source lines from the full conversation export produced 1,317 bytes and the exact transcript-recorded SHA-256. The script reads the PreInvocation input and injects a reminder; it does not parse model output or mechanically admit claims. An earlier discussion said five lifecycle events, but the later exact `hooks.json` evidence showed only `PreInvocation` active and all other event properties null.

FG-v1 reads the YAML frontmatter `name` (falling back to the skill folder name), selects every canonical name beginning `required-gate-`, sorts the matches, rejects duplicate names, reads each selected skill file as UTF-8, adds its path and SHA-256 to the envelope, and assembles one `injectSteps[].ephemeralMessage` for each model invocation. The message says no relevance or applicability test was applied. The original transcript's literal full-body containment check returned `0/8`. A current direct invocation of the packaged hook, with newlines normalized, verified all eight names and complete skill bodies (8/8). This establishes payload generation only; it does not establish AGY runtime consumption or semantic compliance.

The eight names recorded in the setup were:

1. `required-gate-artifact-identity-and-provenance`
2. `required-gate-claim-inference-and-strengthening`
3. `required-gate-claim-output-validation`
4. `required-gate-evidence-source-and-claims`
5. `required-gate-historical-evidence-preservation`
6. `required-gate-readiness-and-completion-criteria`
7. `required-gate-required-actions-and-evidence-necessity`
8. `required-gate-test-scan-results-and-verification`

The prior pre-FG-v1 script was backed up as `.pre-forced-gates-2026-08-18.bak`; the conversation records matching SHA-256 `1965D3BE9814AD3E0E2C1EA204E946B6E55A814FD4F9D702E1A2827D5939BDAB` for that version and its backup, but does not include that older script's full contents. The recovered FG-v1 replacement is source text from the conversation, not a byte-identical recovery of the file that ran on the old profile.

The original R3 discovery scripts produce unprefixed names, but the current package now prefixes all eight canonical frontmatter `name` values and folder names with `required-gate-`. This makes the skill set compatible with FG-v1's prefix scan. The old plugin preview's generated static eight-skill payload remains archived separately; it is not the historical dynamic prefix-scanning script and is not installed.

Google's current documentation describes the default skill flow as discovery followed by relevance-based activation, and documents a `PreInvocation` hook's ability to inject a transient system message before each model call: [Agent skills](https://antigravity.google/docs/skills), [Hooks](https://antigravity.google/docs/hooks/). The archived implementation was observed in the conversation; the current docs are not being used to claim that the old version was byte-identical or that injection guarantees compliance.

## Library and XMemo findings

- The ChatGPT Library contains the Aug 23 `Antigravity_IDE_Setup_Deep_Continuity_Context` note, August 16 research ZIP revisions, and the X1/R1/E2 artifacts. The continuity note contains the long motivation and reports an earlier forced-gate path. It is the source used for [`RATIONALE.md`](RATIONALE.md).
- The August 16 research ZIP contains useful skill-discovery and hook documentation, but also an ESP32-IDE candidate trace with unrelated project identifiers, hashes, and paths. The raw trace is intentionally not copied into this public package; do not publish it unchanged.
- Searches of both connected XMemo accounts found no GEAC/AGY-specific project or memory containing the promised long rationale or missing hook source. XMemo had generic engineering rules only. The public rationale is therefore attributed to the Library continuity note, not XMemo.
- `Release.7z` in Downloads was inspected and contains an unrelated XToolbox Windows application.
- The loose `Apply-GEAC-X1-R1.py` in Downloads matches the R1 patch source; the two R3 scripts are the only loose GEAC-related PowerShell discovery scripts there. X1 and E2 archives contain their own install/restore/verify scripts as shown above.

## Known missing behavioral evidence

The X1 package labels itself an experimental baseline, not a promotion candidate. Its run protocol references the exact SANITY-001 prompt and the R1 patch note names a targeted acceptance replay, but the exact historical prompt, R1 fixture, and raw result were not recovered. Do not claim a measured behavioral improvement until those records are supplied or a new, clearly labeled evaluation is performed.

The shared “Gemini WSL Investigation” conversation frames the bootstrap choice as unresolved and the plugin architecture as a research hypothesis, not a selected release. The Aug 18 census does prove that a global `GEMINI.md` file was present alongside the eight skills and hooks, but it preserves only the 9,544-byte size and SHA-256 above. A same-minute X1-R4 receipt makes an R4 relationship plausible, not proven. The transcript itself cautions that `GEMINI.md`, hooks, or other control-plane text may have changed between Aug 16 and Aug 18. The available X1 experimental `GEMINI.md` is a different hash and is explicitly not a promotion candidate; V1 is an older frozen reference, while V1.1 D1/D2 and E2 are candidate/preview artifacts.

The 2026-10-09 Agy CLI pair included the eight skills and compared FG-v1 disabled versus enabled; it did not include the separate R2 claim-admission hook. The absence of X1's experimental `GEMINI.md` was intentional, not a setup omission. Both runs repeatedly polled background tasks and did not finish the scoped code change. The timings describe that partial configuration; they do not establish whether the earlier setup improved engineering behavior.

