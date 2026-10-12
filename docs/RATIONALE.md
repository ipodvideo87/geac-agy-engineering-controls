# Why GEAC exists

This summary is based on `Antigravity_IDE_Setup_Deep_Continuity_Context_2026-08-23.txt` in the ChatGPT Library. No GEAC-specific XMemo memory was found during recovery.

## The failure GEAC targets

An agent can have engineering rules and still fail to apply them at the moment it reasons, takes action, or writes a result. The continuity record describes a recurring form of over-helpfulness: an agent fills gaps with a plausible story, pursues extra work that was not needed, or reports a stronger conclusion than the evidence supports.

Examples include:

- treating matching names, metadata, or timestamps as proof that two artifacts are the same or that a copy/transfer event occurred;
- carrying test, scan, install, or launch results from one binary to a different binary;
- turning “no record was supplied” into “the event did not happen”;
- turning a successful result into an unsupported claim about the mechanism that produced it;
- treating a recommendation or confidence statement as authorization or as a governing release criterion;
- letting a later fix erase the historical failure or contradiction;
- polishing an uncertain state into a clean-sounding verdict or readiness claim.

These mistakes can make an agent appear helpful while making its engineering output less reliable. In practice, a software engineer must stay within the stated task, separate evidence from inference, preserve artifact identity and history, and stop unsupported transitions from silently becoming facts.

## What the package changes

The historical X1 design organized engineering work as `TASK -> STATE -> OPERATION` and split checks across eight focused skills for evidence, transitions, testing, identity, criteria, authority, history, and reporting. X1-R1 added identity/provenance content: matching metadata does not establish a copy, transfer, derivation, lineage, or acquisition event. The X1 `GEMINI.md` itself is an experimental baseline and is not part of this installable setup.

The Library continuity record says skill discovery did not reliably make all required skills active, so the later setup used a forced-gate/PreInvocation route. The shared conversation documents the standalone `geac-required-gate` hook and treats the larger bootstrap/plugin architecture as still under research. This installer injects the full text of all eight required-gate skills before each model call. A separate R2 hook injects a claim-admission reminder before each invocation; it does not inspect model output or mechanically reject unsupported claims. The exact R4 `GEMINI.md` is recovered and preserved with its eight skills and earlier protocol hook. It explicitly labels itself an experimental baseline and **NOT A PROMOTION CANDIDATE**, so the default installation omits it; an explicit opt-in is available for controlled trials. R3 v2 contains the latest discovery descriptions; R4 later normalized the shared skill-name prefix, and FG-v1 later forced full-skill loading.

## What users should get from it

- Engineering claims that stay tied to their actual sources and exact targets.
- Explicit `NOT_ESTABLISHED` when information is missing instead of an invented negative or explanation.
- No automatic transfer of validation evidence across changed artifacts.
- Clear separation of evidence, inference, status criteria, authority, and recommendation.
- Historical failures and contradictions retained when later corrections occur.
- Bounded tool use and follow-up work, so helpfulness does not become unauthorized or unnecessary activity.

The package changes what is placed in the model's context; it cannot guarantee that a model will obey the instructions. The current build remains experimental until the missing historical fixtures are recovered or a new behavioral evaluation is recorded.

