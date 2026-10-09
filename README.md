# GEAC for Antigravity CLI

Release: GEAC AGY CLI standalone with R3 v2 skill labels and the recovered FG-v1 forced-gate hook

Status: Experimental reconstruction; not promoted or behaviorally validated

License: MIT

GEAC is an engineering-control setup for Google Antigravity CLI (agy). It aims to keep evidence, scope, identity, verification, authority, and completion claims bounded during software-engineering work. It was created because a general-purpose agent can overextend its helpfulness by doing extra research or work, or by strengthening claims beyond the evidence. The PreInvocation hook forces eight focused skills into each model invocation.

This is a standalone global CLI installation. It installs skills and hooks only; it does not install a plugin or a global `GEMINI.md` kernel. The conversation also records a separate global `GEMINI.md` present during the historical eight-skill setup (9,544 bytes; SHA-256 `96231f08f168d877912e2503b4059026dda34e2fb00512c20c096d34cfa50cdf`). Its exact contents were not recovered, and it differs from the 9,407-byte X1 kernel in the baseline archive. The available X1 kernel is explicitly marked as an experimental baseline, so the installer does not substitute it for the unrecovered active file. The preserved X1 and V1 kernel files are reference material only.

## What is included

- Eight focused skills with the R3 v2 descriptions and the shared required-gate- prefix.
- The later X1-R1 identity and provenance content under the R3 v2 skill name.
- The transcript-recovered FG-v1 PowerShell PreInvocation hook. It selects every skill whose canonical name starts with required-gate- and injects its full SKILL.md text on every model invocation.
- The original X1-R2 claim-admission hook, recovered word-for-word from the conversation export and verified against its recorded 1,317-byte size and SHA-256. The exact later hook configuration shows it registered for `PreInvocation` only.
- Windows PowerShell install, verify, and restore scripts.
- Source-recovery notes, rationale, Order-of-Engineering and agent/subagent research notes, manifests, and preserved kernel candidates.

The eight skill names are:

1. required-gate-action-authorization-and-necessity
2. required-gate-readiness-and-completion-criteria
3. required-gate-evidence-source-and-claims
4. required-gate-historical-evidence-preservation
5. required-gate-artifact-identity-and-provenance
6. required-gate-claim-output-validation
7. required-gate-test-scan-results-and-verification
8. required-gate-claim-inference-and-strengthening

## How the forced state works

Antigravity normally makes skills available by name and description, then uses relevance to decide whether to read the full skill. The enabled FG-v1 PreInvocation hook bypasses that relevance decision for required-gate skills: it mechanically reads and injects every matching skill body before each model call. Other skills remain under normal Antigravity selection.

This guarantees that the skill text is included in the hook output when it runs. It does not guarantee that the model follows the instructions. Injecting all eight skill bodies on every model call adds context and may increase response time. This package has not established a behavioral or timing improvement.

The claim-admission hook also injects a transient reminder before each invocation. It does not inspect the generated answer or mechanically accept/reject claims. The transcript's exact hook configuration showed only `PreInvocation`; an earlier five-event description was corrected by the later configuration evidence.

The CLI skill paths and hook registry follow Antigravity's documented global locations. See the official documentation for [Agent skills](https://antigravity.google/docs/skills) and [Lifecycle hooks](https://antigravity.google/docs/hooks).

## Install on Windows

Prerequisites: Antigravity CLI and Windows PowerShell. If an older GEAC plugin is enabled, disable or uninstall it first to avoid loading duplicate instructions. The installer refuses to proceed while that plugin is enabled.

From the extracted repository directory, run:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-GEAC-R3-V2.ps1

The installer backs up files it will replace under the user's .gemini/geac-backups directory, installs eight skills and two PreInvocation hooks, then runs the file and hook-payload verifier. It leaves the user's global `GEMINI.md` untouched and stops if it finds the known X1 experimental kernel there. Save the printed backup path.

## Verify and restore

Verify the installed bytes, hook registration, and direct hook output without starting an Agy model task:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Verify-GEAC-R3-V2.ps1

Restore the pre-install files using the backup path printed by the installer:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Restore-GEAC-R3-V2.ps1 -BackupPath "C:\Users\<you>\.gemini\geac-backups\GEAC-R3-V2-FGv1\<timestamp>"

These checks establish file integrity, hook registration, and payload generation. They do not establish model compliance, software-engineering quality, or faster replies.

## Recovery status and evidence

R3 v2 is the latest recovered skill wording and label update. X1-R1 supplies later identity/provenance content, and FG-v1 is the recovered forced-skill hook. The installable setup combines the eight R3 v2-labeled skills, the X1-R1 identity content, FG-v1, and the transcript-recovered R2 claim-admission reminder. The X1 global `GEMINI.md` is excluded from installation because it identifies itself as an experimental baseline and explicitly not a promotion candidate; V1 and X1 kernel files are preserved as reference candidates.

The October 9 paired Agy CLI run included the skills and compared FG-v1 disabled versus enabled. It did not include the separate historical R2 claim-admission hook; that source has since been recovered from the full conversation export and verified against its recorded size and SHA-256. Both runs failed to implement the scoped code task. Treat the timings as observations of that partial configuration, not proof of the former setup's engineering effect.

The full conversation export contains the original R2 script. Its recovered bytes match the transcript-recorded size and SHA-256 exactly. The exact historical SANITY-001 prompt and R1 identity acceptance fixture are still missing. Treat this package as an experimental recovery, not as proof of effectiveness.

## Source and format references

- docs/SOURCE-RECOVERY.md: recovered lineage, completeness audit, and known gaps.
- docs/RATIONALE.md: the motivation and engineering-control goals.
- reference/source/historical-hooks/: transcript-recovered FG-v1 and R2 hook sources and provenance notes.
- reference/source/kernel-candidates/: frozen V1 kernel reference; X1 is preserved under reference/source/x1-original/ and explicitly not promoted. No kernel is installed by this package.
- docs/ARCHITECTURE-IDEAS.md: Order-of-Engineering, bootstrap, plugin, and agent/subagent ideas from the research conversation; these remain design research.
- reference/source/r3-skill-discovery/: the two original R3 discovery scripts.
- PACKAGE-MANIFEST.json and PACKAGE-SHA256.txt: package file inventory and hashes.
- SOURCE-PAYLOAD-SHA256.txt: hashes for the eight skill files installed by the setup.
