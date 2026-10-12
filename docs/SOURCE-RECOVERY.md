# GEAC source recovery and completeness audit

Audit date: 2026-10-12. This records what was recovered, what belongs in the installable package, and what remains missing. Historical files are kept separate from the current installer payload.

## Recovered implementation lineage

| Stage | Recovered source | What it contains | Packaging treatment |
|---|---|---|---|
| V1 / V1.1 | `GEAC-2026-08-14-V1.zip`, `GEAC_V1_1_Candidate_D2.zip` | Earlier candidate architecture and policy drafts | V1 ZIP is retained in the local recovery copy but omitted from this public copy because its README embeds a local Windows user path; V1.1 is preserved under `reference/source/archives/` |
| E2 | `GEAC_E2_PREVIEW_01.zip`, `GEAC_E2_PREVIEW_02.zip`, `GEAC_E2_IMPORT_PROBE_01.zip` | Later previews and an import probe; the probe has its own install/restore PowerShell scripts | Preserved under `reference/source/archives/`; not the R1 release |
| X1 | `GEAC_X1_EXPERIMENTAL_BASELINE.zip` and its extracted source tree | Experimental `GEMINI.md` kernel, eight skills, PowerShell install/restore/verify, Python manifest builder and package-test source, manifests, design basis, and experiment protocol | Historical source is preserved under `reference/source/x1-original/`. The kernel explicitly says it is not a promotion candidate and is excluded from the active installer. A copy from the prior plugin preview is archived under `reference/source/legacy-plugin-preview/`. The exact ZIP remains in the local recovery copy; original SHA-256 is recorded in `SOURCE-BASIS.json` |
| X1-R1 | `GEAC_X1_R1_IDENTITY_PATCH.zip` | Python identity/provenance patcher, its test source, change note, README, and output hash | Exact ZIP is preserved under `reference/source/archives/`; the X1-R1 identity/provenance change is incorporated into the standalone skill payload |
| R3 discovery | `Update-Gemini-Skill-Discovery.ps1` and `Update-Gemini-Skill-Discovery-v2.ps1` | Renames the eight skills and rewrites discovery descriptions plus references in `GEMINI.md` | Both exact scripts are preserved under `reference/source/r3-skill-discovery/`; neither is run by the installer |
| X1-R4 | Recovered former Antigravity profile and its `X1-R4` receipt | Exact R4 `GEMINI.md`, eight normalized `required-gate-*` skills, the pre-FG-v1 mandatory-if-applicable `PreInvocation` protocol hook, and a redacted hook registry | Byte-exact snapshot is preserved under `reference/source/historical-setups/X1-R4/`; the kernel is excluded from the default install but available through an explicit trial opt-in |
| FG-v1 hook | Shared ChatGPT conversation and recovered former profile | Later forced-loading PowerShell hook, registered at `PreInvocation`, scans the shared prefix and injects every matching full skill body | Exact active file is preserved under `reference/source/historical-hooks/` and used by the standalone installer |

The source X1 tree contains the eight skill files and the Python files `tools/build_manifest.py` and `tests/test_x1_package.py`. The preserved R1 archive contains `Apply-GEAC-X1-R1.py` and `test_apply_geac_x1_r1.py`; the identity/provenance change is incorporated into the active skill. Test files are preserved inside the source archives; they were not run for this packaging task.

## Revision path to the latest recovered standalone setup

This sequence records which earlier changes flow into the installable setup and which later-looking material remained exploratory. R3 v2 is the latest discovery-description wording; R4 is later for shared labels and protocol-hook state; FG-v1 is later again for forced loading. The conversation does not finalize a promoted global kernel or plugin release.

| Revision or evidence | Change as the work progressed | Current package treatment |
|---|---|---|
| Frozen GEAC V1 reference | Established an earlier engineering-contract baseline. | Its original ZIP remains in Downloads and is omitted from this release because its README embeds a local Windows user path. Its `GEMINI.md` was not selected for this installer. |
| V1.1 D1/D2 and E2 previews | Explored later control boundaries and packaging options. | D2 and E2 archives are included as previews; D1 remains in the local recovery library. None is promoted into the standalone setup. |
| X1 experimental baseline | Reworked the control set into eight engineering skills and a global `GEMINI.md`. | The skills supply the base content. The kernel is explicitly marked “NOT A PROMOTION CANDIDATE” and is not installed. |
| X1-R1 identity/provenance revision | Added explicit rules against inferring a copy, transfer, lineage, generation, or acquisition event from metadata alone. | Incorporated into `required-gate-artifact-identity-and-provenance`. |
| R3 v1, then R3 v2 skill discovery wording | Renamed the skills and broadened their descriptions for relevance-based discovery; v2 is the latest recovered discovery wording. | Uses all eight R3 v2 descriptions, safely quoted in YAML. |
| X1-R4 identifier normalization | Later than R3 v2: normalized all eight canonical skill names to the shared `required-gate-` prefix and added a separate mandatory-if-applicable `PreInvocation` protocol hook. Its receipt says skill bodies and descriptions were unchanged. | Exact R4 kernel, skills, hook, redacted registry, and redacted receipt are preserved as a historical snapshot. The installer uses the R4 identifiers and offers the kernel only through an explicit trial opt-in. |
| FG-v1 forced-loading hook | Later than R4: the active hook was replaced with a loader that injects every matching full skill body at `PreInvocation`. | Exact active source is preserved and enabled by the standalone installer. It forces context inclusion, not model compliance. |
| Separate R2 claim-admission hook | The full conversation export contains the 36-line source and a later exact configuration. The configuration corrects an earlier five-event description: only `PreInvocation` has a handler; the other event fields are `null`. | Exact script recovered as 1,317 bytes and verified against transcript SHA-256 `927f307b30a56a33f88cc7fb23d2651a5047a16155e82ddce728112fe5d70b6d`; installed as a separate `PreInvocation` hook. |
| X1-R4 `GEMINI.md` | Recovered exact active-profile file is 9,544 bytes and SHA-256 `96231f08f168d877912e2503b4059026dda34e2fb00512c20c096d34cfa50cdf`, exactly matching the R4 receipt's `postSha256`. | Preserved byte-for-byte under `reference/source/historical-setups/X1-R4/`. It declares itself experimental and **NOT A PROMOTION CANDIDATE**, so it is not installed. It differs from the 9,407-byte X1 baseline kernel. |
| Later CLI/plugin research | Considered plugin composition, bootstrap ownership, hook ordering, authorization, telemetry, agents, and context accounting. The conversation labels this a research architecture and leaves the bootstrap owner unresolved. | These proposals are documented in `docs/ARCHITECTURE-IDEAS.md`; they are not presented as completed installer features. No plugin is installed. The R4 kernel is omitted by default and available for an explicit trial opt-in. |

This ledger is a change-coverage summary, not a verbatim transcript. It distinguishes adopted changes from proposals so the package does not silently turn an experiment into a release decision.

## What the R3 scripts do

The two R3 PowerShell scripts do **not** force all eight skills on. They rename skills and broaden their frontmatter descriptions so the agent is more likely to select them during its relevance-based discovery. The v2 script is later than v1. It writes new description values as unquoted YAML plain scalars, including values containing `: `; the continuity record says that malformed descriptions caused skills to disappear from discovery. The current package uses the eight R3 v2 descriptions, safely quoted as YAML strings, and the shared R4 `required-gate-` identifiers for FG-v1 compatibility. Keep the original scripts as historical references and do not run them as the auto-on mechanism.

## Recovered standalone forced-gate hook

A previously unexamined shared ChatGPT conversation and the recovered former profile contain the final FG-v1 revision of `geac-required-gate.ps1`. The active former-profile file and the packaged source are byte-identical: 6,737 bytes, SHA-256 `d9aec018798b0b2eeb04f13bd738327839afb643900e9e294a57fe1d03ad2f2d`. It is kept at [`reference/source/historical-hooks/geac-required-gate.fg-v1.ps1`](../reference/source/historical-hooks/geac-required-gate.fg-v1.ps1).

The full R4 snapshot is preserved at [`reference/source/historical-setups/X1-R4/`](../reference/source/historical-setups/X1-R4/). Its exact `GEMINI.md` hash matches the R4 receipt, and each of its eight skill-file hashes matches the receipt. The R4 pre-FG-v1 hook backup also matches its recorded SHA-256. The later FG-v1 hook is the active forced loader included by the current standalone installer. This source recovery does not establish that the R4 kernel was promoted or that any setup achieved behavioral compliance.

- Hook registry: `~/.gemini/config/hooks.json`.
- Hook script: `~/.gemini/config/hooks/geac-required-gate.ps1`.
- Skill root: `~/.gemini/antigravity-cli/skills/<skill-folder>/SKILL.md`.
- Hook entry: `geac-required-gate`, enabled, with a `PreInvocation` command using `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` and a 10-second timeout.
- The hook was separate from `geac-x1-r2-claim-admission`, another global `PreInvocation` hook for claim controls. The R4 registry omits the R2 hook's optional `enabled` field; current official documentation says the default is enabled, and the installer makes it explicit. The auto-load mechanism itself did not require a plugin.

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

The pre-FG-v1 R4 protocol hook backup is preserved at [`reference/source/historical-setups/X1-R4/hooks/geac-required-gate.r4-protocol-hook.ps1`](../reference/source/historical-setups/X1-R4/hooks/geac-required-gate.r4-protocol-hook.ps1); its bytes match the R4 receipt's SHA-256 `1965d3be9814ad3e0e2c1ea204e946b6e55a814fd4f9d702e1a2827d5939bdab`. The later FG-v1 replacement also matches the active former-profile file byte-for-byte. FG-v1 supersedes the R4 protocol hook in the recovered chronology; the hooks have distinct message behavior, and the receipt does not prove runtime skill listing or model behavior.

The original R3 discovery scripts produce unprefixed names, but the current package now prefixes all eight canonical frontmatter `name` values and folder names with `required-gate-`. This makes the skill set compatible with FG-v1's prefix scan. The old plugin preview's generated static eight-skill payload remains archived separately; it is not the historical dynamic prefix-scanning script and is not installed.

Google's current documentation describes the default skill flow as discovery followed by relevance-based activation, and documents a `PreInvocation` hook's ability to inject a transient system message before each model call: [Agent skills](https://antigravity.google/docs/skills), [Hooks](https://antigravity.google/docs/hooks/). The archived implementation was observed in the conversation; the current docs are not being used to claim that the old version was byte-identical or that injection guarantees compliance.

## Library and XMemo findings

- The ChatGPT Library contains the Aug 23 `Antigravity_IDE_Setup_Deep_Continuity_Context` note, August 16 research ZIP revisions, and the X1/R1/E2 artifacts. The continuity note contains the long motivation and reports an earlier forced-gate path. It is the source used for [`RATIONALE.md`](RATIONALE.md).
- The August 16 research ZIP contains useful skill-discovery and hook documentation, but also an ESP32-IDE candidate trace with unrelated project identifiers, hashes, and paths. The raw trace is intentionally not copied into this public package; do not publish it unchanged.
- Searches of both connected XMemo accounts found no GEAC/AGY-specific project or memory containing the promised long rationale or missing hook source. XMemo had generic engineering rules only. The public rationale is therefore attributed to the Library continuity note, not XMemo.
- A local Codex-session sweep covered current, legacy, recovered-Windows-old, and Administrator-profile session exports, plus both compressed `.codex` backups. The backups contain six unique session logs across eleven copies: five are byte-identical duplicates, and the extra July session has no AGY/GEAC references. The relevant Codex sessions point back to the ChatGPT setup conversations and the full “Gemini WSL Investigation” export; they did not reveal another later implementation payload.
- `Release.7z` in Downloads was inspected and contains an unrelated XToolbox Windows application.
- The loose `Apply-GEAC-X1-R1.py` in Downloads matches the R1 patch source; the two R3 scripts are the only loose GEAC-related PowerShell discovery scripts there. X1 and E2 archives contain their own install/restore/verify scripts as shown above.

## Known missing behavioral evidence

The X1 package labels itself an experimental baseline, not a promotion candidate. Its run protocol references the exact SANITY-001 prompt and the R1 patch note names a targeted acceptance replay, but the exact historical prompt, R1 fixture, and raw result were not recovered. Do not claim a measured behavioral improvement until those records are supplied or a new, clearly labeled evaluation is performed.

The shared “Gemini WSL Investigation” conversation frames the bootstrap choice as unresolved and the plugin architecture as a research hypothesis, not a selected release. The exact Aug 16 X1-R4 `GEMINI.md` is now recovered and its hash matches the R4 receipt; it is not the different 9,407-byte X1 baseline file. This proves the recovered R4 file's identity, not that it remained active or was promoted after Aug 16. It explicitly marks itself as an experimental baseline and **NOT A PROMOTION CANDIDATE**. V1 is an older frozen reference, while V1.1 D1/D2 and E2 are candidate/preview artifacts.

The 2026-10-09 Agy CLI pair included the eight skills and compared FG-v1 disabled versus enabled; it did not include the separate R2 claim-admission hook. The absence of X1's experimental `GEMINI.md` was intentional, not a setup omission. Both runs repeatedly polled background tasks and did not finish the scoped code change. The timings describe that partial configuration; they do not establish whether the earlier setup improved engineering behavior.

The 2026-10-12 read-only review included the exact R4 kernel, all eight R4-named skills, FG-v1, and R2. AGY CLI 1.3.2 produced no final response after approximately 10 minutes 17 seconds; it made file-view calls but ran no commands or tests and changed no source files. The model was not pinned. See [`TRIAL-2026-10-12.md`](TRIAL-2026-10-12.md). This records a long delay, not a behavioral result or diagnosis.

