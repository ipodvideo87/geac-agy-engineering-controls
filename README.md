# GEAC X1-R1 Plugin Preview

**Release:** `GEAC-X1-R1-PLUGIN-PREVIEW-2026-10-03`  
**Status:** Experimental reconstruction; not promoted or behaviorally validated.
**License:** [MIT](LICENSE).

This package preserves the X1 baseline and the X1-R1 identity/provenance revision, then adapts them to an Antigravity plugin. It also reconstructs the missing always-on skill behavior with a `PreInvocation` hook that injects the complete text of all eight skills before every model call. The historical hook source was not recovered; this hook is a new, explicitly labeled reconstruction.

## Included components

- `plugin/rules/GEMINI.md`: the always-on X1 task/state/operation control kernel.
- `plugin/skills/`: all eight focused GEAC skills with the final names and discovery wording from the later R3 v2 script: action authorization, readiness criteria, evidence, history, artifact identity, output claims, test/scan verification, and inference strengthening. Descriptions are quoted as YAML strings so the colon-bearing R3 wording parses correctly.
- X1-R1 identity/provenance skill content retained under the R3 v2 skill name `artifact-identity-and-provenance`. The archived R1 output hash is `0dd2355ee3bd513bd6bb155b48f0ba9b7be747ca3d7f1834012ea3354aea2f50`; R3's name and description updates change the current file bytes.
- `plugin/plugin.json`: the native Antigravity plugin manifest.
- `install/hooks.windows.json` and `install/hooks.unix.json`: platform-specific hook registrations. The matching installer stages one as `hooks.json` before calling AGY.
- `plugin/scripts/`: Windows and Unix hook emitters plus the generated pre-invocation payload. The payload unconditionally loads all eight skill instructions into system context each time the model is called.
- `tools/build_auto_state_payload.py`: regenerates the all-eight-skill payload from the canonical installed skill files.
- `tools/build_package_manifests.py`: regenerates package and plugin SHA-256 manifests after source changes.
- Install, verify, and uninstall commands using the AGY plugin manager.
- `reference/source/`: recovered X1 source tree, selected E2/R1 candidate archives, both R3 discovery scripts, and historical design notes. Two original ZIPs whose README examples contained a local Windows user path remain in the private recovery copy; their provenance is recorded, but those ZIPs are omitted here.
- `docs/`: the source-recovery audit and the rationale distilled from the August continuity document.

No MCP server or custom agent is included: neither is part of the frozen X1-R1 payload. The package manifest and native plugin manifest are the additional packaging pieces.

## Always-on skill state

The installed R3 v2 skill labels and discovery descriptions are:

| Skill name | Discovery description |
|---|---|
| `action-authorization-and-necessity` | STOP AND CHECK AUTHORIZATION OR NECESSITY: Use this skill whenever considering tools, searches, commands, mutations, research, additional evidence, or operational next steps, or whenever reasoning or output says an action is required, necessary, optional, blocking, authorized, permitted, recommended, executable, or should be performed. |
| `readiness-and-completion-criteria` | STOP AND CHECK THE CRITERION: Use this skill whenever a status or conclusion says or implies ready, safe, pass, fail, correct, complete, acceptable, compliant, validated, releasable, or satisfied, especially when it depends on a policy, threshold, definition, requirement, or acceptance rule. |
| `evidence-source-and-claims` | STOP AND CHECK THE SOURCE: Use this skill whenever factual information enters engineering reasoning, a material claim depends on supplied, observed, reported, asserted, verified, absent, unknown, missing, or conflicting information, or a closed evidence boundary matters. |
| `historical-evidence-preservation` | STOP AND CHECK HISTORY: Use this skill whenever evidence or engineering state changes over time, or later success, failure, contradiction, remediation, replacement, revision, reconstruction, or new evidence could be interpreted as changing, erasing, or rewriting an earlier record or state. |
| `artifact-identity-and-provenance` | STOP AND CHECK IDENTITY AND PROVENANCE: Use this skill whenever a claim depends on sameness, byte equality, artifact identity, generation, lineage, derivation, provenance, hashes, paths, metadata, IDs, timestamps, namespaces, or transfer history. |
| `claim-output-validation` | STOP AND CHECK THE OUTPUT CLAIM: Use this skill whenever writing, emitting, or reformulating a material case-specific engineering conclusion, explanation, heading, table entry, summary, recommendation, verdict, status statement, completion claim, self-review, or other output claim. |
| `test-scan-results-and-verification` | STOP AND CHECK THE TEST OR SCAN CLAIM: Use this skill whenever tests, scans, validation results, pass/fail outcomes, test execution, assertions, coverage, test scope, test runners, verification, safety, readiness, correctness, or proposed test or scan evidence are involved. |
| `claim-inference-and-strengthening` | STOP AND CHECK THE INFERENCE: Use this skill whenever evidence or prior claims are combined, paraphrased, explained, generalized, strengthened, or used to infer a new proposition, especially mechanism, causality, scope, certainty, probability, provenance, identity, criterion, actor, environment, implementation, or authority. |

Antigravity Skills are normally made available to the model by name and description, and the agent decides whether to read a skill based on relevance. This package overrides that selection step: an enabled `PreInvocation` hook injects all eight full `SKILL.md` files before every model invocation. The installed labels and descriptions use the final R3 v2 wording. The agent is instructed to consider every skill and mark an irrelevant domain `NOT_APPLICABLE`; it must not omit the skill because it judged it irrelevant before reading it.

This guarantees that the skill text is present in the invocation context when the hook runs. It does not guarantee model compliance, and it adds the eight skill texts to each model call. This mechanism is a reconstruction of the missing historical always-on script, based on Antigravity's documented `PreInvocation` ephemeral system-message interface.

## Install

Requires Antigravity CLI (`agy`) 1.2.7 or later.

Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-GEAC-X1-R1.ps1
```

Linux or macOS:

```sh
sh ./install-geac-x1-r1.sh
```

The installer verifies the release checksums, stages the platform-specific `hooks.json`, asks AGY to validate the plugin, and installs it into the CLI plugin directory. It refuses to overwrite a plugin already installed under the same name.

## Verify and remove

Run the platform verification script after installation:

```powershell
.\Verify-GEAC-X1-R1.ps1
```

```sh
sh ./verify-geac-x1-r1.sh
```

AGY also provides `/skills` and `/hooks` in an interactive CLI session for checking discovery and hook registration. These checks establish visibility and registration only; they do not prove behavioral compliance.

To remove the package:

```sh
agy plugin uninstall geac-x1-r1-engineering-controls
```

## Behavioral evidence still required

The source X1 package explicitly says it is an experimental behavioral baseline, not a promotion candidate. Its first-run protocol requires the exact historical SANITY-001 prompt, but that prompt is not embedded in the source package. The R1 patch note also names a targeted identity/provenance acceptance result without including the exact historical fixture and raw replay. These missing records were not reconstructed. The all-eight-skill hook is a new implementation and still needs a fresh-session behavior comparison; installation and byte-hash checks establish package integrity only.

Use the archived micro-regression prompts and `X1-RUN-RECORD-TEMPLATE.md` under `reference/x1/experiments/` after the exact integration prompt is recovered. Keep any future behavior change under a new package revision rather than editing installed files in place.

## Source and format references

- [Antigravity Plugins](https://antigravity.google/docs/plugins)
- [Antigravity Lifecycle Hooks](https://antigravity.google/docs/hooks)
- [Antigravity Agent Skills](https://antigravity.google/docs/skills)

`SOURCE-BASIS.json`, `PLUGIN-SHA256.txt`, `PACKAGE-SHA256.txt`, and `PACKAGE-MANIFEST.json` record source provenance and expected bytes. See [`docs/SOURCE-RECOVERY.md`](docs/SOURCE-RECOVERY.md) for the full search boundary and known gaps.
