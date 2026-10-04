# X1 First Behavioral Run — SANITY-001 Integration Baseline

**Candidate:** `GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE`  
**Purpose:** First uncontaminated behavioral comparison of B0 (Preview-02) against X1.  
**Status:** Integration experiment only; not promotion evidence.

## Critical prompt-integrity rule

The exact preserved historical SANITY-001 prompt is **not embedded in this package because its exact original text was not available to the build workspace**.

**DO NOT RECONSTRUCT, paraphrase, improve, shorten, or regenerate it from the old response.** Doing so would create a different test.

Before the first X1 behavioral run, obtain the **exact preserved historical SANITY-001 prompt** from its authoritative preserved source. If an exact prompt file exists, compute and record its SHA-256 before use. If only the original conversation message is authoritative, paste that exact message unchanged and record that acquisition source in the run record.

If the exact prompt cannot be recovered, stop this integration replay and classify `EXACT_REPLAY = NOT_ESTABLISHED`. Do not silently substitute a reconstructed prompt.

## Preconditions

1. Install X1 with `Install-GEAC-X1.ps1` and preserve the printed backup path.
2. Run `Verify-GEAC-X1.ps1`; all nine managed files must match the X1 payload manifest.
3. Launch `agy` in a **fresh `agy` session** after installation.
4. Optionally open `/skills` only to verify the eight X1 skill names are discoverable; do not manually invoke a skill for the baseline replay unless the historical B0 run did so.
5. Do not run any diagnostic micro-prompt before SANITY-001 in that fresh session.
6. Do not tell Gemini what Preview-02 got wrong.

## First run

Paste the exact preserved SANITY-001 prompt unchanged as the first substantive engineering prompt.

This must occur **before any micro-regression**.

Do not edit X1 files while the run is active.

## Preserve immediately

Save the raw response unchanged. Record:

- X1 contract ID;
- exact `X1-PAYLOAD-MANIFEST.json` SHA-256;
- installed `GEMINI.md` SHA-256;
- eight installed skill SHA-256 values;
- `agy` version if already available without modifying the session;
- model/configuration shown for the run;
- prompt provenance and prompt SHA-256 when a file exists;
- raw response path and SHA-256;
- session freshness statement;
- whether `/skills` showed the X1 skills, if checked;
- any unexpected host/loading behavior.

## Initial comparison dimensions

Compare B0 and X1 clause by clause for at least:

- exact artifact identity;
- source label versus controlled `VERIFIED` state;
- `NOT_SUPPLIED` versus `NOT_PERFORMED`;
- pipeline outcome versus invented execution mechanics;
- test result versus invented runner/assertion/coverage semantics;
- scan report versus invented scanner mechanics;
- missing READY criterion versus invented requirements;
- expected hash versus actual/computed artifact state;
- metadata correlation versus transfer/copy causal story;
- proposed evidence overclaim;
- cross-section persistence after a correct headline.

## Stop boundary

After preserving the raw X1 response, end the baseline run. Do not patch X1 in place. Any architecture change becomes `X1-R1` or later and requires its own exact identity.
