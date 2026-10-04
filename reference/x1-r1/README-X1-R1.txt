GEAC X1-R1 — SINGLE-SKILL IDENTITY/PROVENANCE REVISION
========================================================

Purpose
-------
Apply exactly one behavioral control-surface change to the installed GEAC X1
baseline: geac-x1-engineering-identity.md.

Observed X1 residual being targeted
------------------------------------
The baseline result for "No metadata -> copy/transfer-event conclusion" was
"mostly" rather than fully clean. X1 already rejected exact-artifact and
same-generation upgrades, but the identity/provenance owner did not explicitly
preserve metadata correlation separately from an unsupplied copy/transfer/
lineage/acquisition event.

Revision
--------
Parent: X1
Revision: X1-R1
Revision ID: GEAC-2026-08-15-X1-R1-IDENTITY-PROVENANCE-BOUNDARY

Only X1-managed file changed:
  .gemini/antigravity-cli/skills/geac-x1-engineering-identity.md

Frozen X1 parent SHA-256:
  f32177a8012cba43ec466bf55cac1608bf1aafd37e433b0a899ce91d63fd67fa

Precommitted X1-R1 SHA-256:
  0dd2355ee3bd513bd6bb155b48f0ba9b7be747ca3d7f1834012ea3354aea2f50

Safety / verification behavior
------------------------------
Apply-GEAC-X1-R1.py:
  1. requires all nine installed X1-managed files to match the frozen X1 hashes;
  2. refuses to patch an unknown or locally modified parent state;
  3. makes a timestamped byte-identical backup of the identity skill;
  4. applies one exact byte transformation at one exact anchor;
  5. requires the transformed identity skill to match the precommitted R1 hash;
  6. verifies every other X1-managed file remains at its X1 hash;
  7. writes a local revision receipt under ~/.gemini/geac-revisions/X1-R1/;
  8. rolls the identity skill back to exact X1 bytes if a post-commit check fails;
  9. on a second run, verifies and reports an already-installed exact R1 state.

Normal Windows use
------------------
Run the script with the same Windows user account that has X1 installed.
No --home argument is needed for normal use.

Example using the Python installation already used for the GEAC/StoreDiag work:

  C:\Python314\python.exe Apply-GEAC-X1-R1.py

Do not have an agy behavioral test session open while applying the revision.
After the script reports APPLIED_AND_VERIFIED, start a fresh agy session and
rerun the exact X1-BASELINE-001 prompt. Preserve the raw response before making
any further edit.

Acceptance target for the behavioral replay
-------------------------------------------
The previous "No metadata -> copy/transfer-event conclusion" result should move
from "mostly" to fully clean, while all previously clean central controls remain
clean. The local byte verifier does not establish behavioral effectiveness;
that is established only by the fresh behavioral run and its evaluation.
