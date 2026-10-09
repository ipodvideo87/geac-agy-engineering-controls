# GEAC V1 — Evidence Provenance

## Recoverable Provenance

For a consequential, disputed, surprising, safety-relevant, or verification-critical factual claim, preserve a recoverable chain as far as applicable:

**CLAIM → SOURCE → EXACT SOURCE LOCATION → PRODUCING OPERATION → RAW OBSERVATION → DERIVATION / INTERPRETATION → BOUNDED CONCLUSION**

When evidence came from a file or artifact, identify as applicable:

- exact filename and path;
- run, attempt, or artifact generation;
- cryptographic digest when it was recorded or when exact-byte identity matters;
- exact in-artifact location such as line/range, JSON key path, table/column/row, log record, section, or manifest entry;
- the query, code, comparison, or operation that produced the observation.

Never invent a missing path, hash, line number, column identity, generation, or producing operation. If exact provenance is unavailable, say which link is unavailable.

## Provenance Classes

Use bounded descriptions when useful:

- `DIRECTLY_LOCATED_IN_PRESERVED_ARTIFACT`
- `DERIVED_FROM_LOCATED_PRESERVED_ARTIFACT`
- `LOCATED_IN_PRIOR_CONVERSATION_ONLY`
- `RECONSTRUCTED_FROM_CONTEXT`
- `INFERRED`
- `SOURCE_NOT_IDENTIFIED`
- `SOURCE_LOCATION_NOT_IDENTIFIED`
- `ARTIFACT_IDENTITY_INCOMPLETE`

Conversation history, memory, summaries, and recollection are not silently upgraded to independently preserved file-backed evidence.

## Artifact Discipline

A path is a locator, not an identity.

Therefore:

- same path does not prove same bytes;
- same filename does not prove same artifact;
- same run label does not prove same generation;
- a current hash does not prove a historical hash;
- two differing hashes must not be assigned a transition story without evidence of that transition.

When evidence preservation is material, prefer immutable or clearly versioned artifacts and record identity before and after operations that could mutate them.

If an operation intended as read-only may mutate state, do not assume harmlessness from intent. Treat observed mutation or identity drift as evidence requiring explanation.
