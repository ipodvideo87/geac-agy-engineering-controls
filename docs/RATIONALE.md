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

GEAC X1 organizes engineering work as `TASK -> STATE -> OPERATION`. A small global kernel holds the shared invariants and eight focused skills own evidence, transitions, testing, identity, criteria, authority, history, and reporting. X1-R1 adds a narrow identity/provenance boundary: matching metadata does not establish a copy, transfer, derivation, lineage, or acquisition event.

The recovered X1 design used an always-on kernel with selectively activated skills. The Library continuity record says that skill discovery did not reliably make all required skills active, so a later forced-gate/PreInvocation route was explored. Its source code was not recovered. This installer reconstructs the intended always-on behavior by injecting the full text of all eight skills before each model call. The agent then marks unused domains `NOT_APPLICABLE` rather than deciding whether to load their instructions.

## What users should get from it

- Engineering claims that stay tied to their actual sources and exact targets.
- Explicit `NOT_ESTABLISHED` when information is missing instead of an invented negative or explanation.
- No automatic transfer of validation evidence across changed artifacts.
- Clear separation of evidence, inference, status criteria, authority, and recommendation.
- Historical failures and contradictions retained when later corrections occur.
- Bounded tool use and follow-up work, so helpfulness does not become unauthorized or unnecessary activity.

The package changes what is placed in the model's context; it cannot guarantee that a model will obey the instructions. The current build remains experimental until the missing historical fixtures are recovered or a new behavioral evaluation is recorded.

