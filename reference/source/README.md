# Preserved source material

This directory holds recovered historical sources for traceability. Files under `archives/`, `x1-original/`, and `r3-skill-discovery/` are not installed by the current package installer.

- `x1-original/` is the complete extracted X1 experimental baseline from Downloads, including the original installer, restore and verify scripts, all eight source skills, Python manifest builder, test source, design, and run protocol.
- `archives/` holds selected R1 and E2 source ZIPs. The original X1 baseline and V1 ZIPs are retained in the local recovery copy but omitted from this public copy because their README examples contain a local Windows user path; the extracted X1 files and original X1 archive hash are retained here.
- `r3-skill-discovery/` holds the two original discovery-description PowerShell scripts. They rename and describe skills but do not force them to load.
- `historical-notes/` holds the downloaded D2 semantic-hardening note.

Do not execute archived installers or R3 scripts as a substitute for the current package installer. The R3 descriptions need YAML correction, and the original X1 install layout predates this plugin package.

The installed skill names and descriptions use the later R3 v2 wording. The package quotes those descriptions as YAML strings to preserve the exact wording while keeping frontmatter parseable. Forced all-eight loading is provided separately by the reconstructed PreInvocation hook; no historical hook script was recovered. The X1 extracted README's example backup path was normalized to `%USERPROFILE%` in this public copy; the local recovery copy preserves the original text.

