# X1-R4 historical snapshot

This folder preserves exact source files recovered from the former Antigravity CLI profile for revision X1-R4. It is historical reference material. The installer uses the exact R4 skill labels and offers the kernel only through an explicit experimental trial opt-in.

## Snapshot contents

- `GEMINI.md`: the 9,544-byte R4 global kernel. Its SHA-256 `96231f08f168d877912e2503b4059026dda34e2fb00512c20c096d34cfa50cdf` matches the R4 receipt's `geminiMd.postSha256`.
- `skills/`: all eight normalized `required-gate-*` skill files. Every file SHA-256 matches its `postFileSha256` in the R4 receipt.
- `hooks/geac-required-gate.r4-protocol-hook.ps1`: the pre-FG-v1 R4 `PreInvocation` protocol hook. Its SHA-256 `1965d3be9814ad3e0e2c1ea204e946b6e55a814fd4f9d702e1a2827d5939bdab` matches the receipt's recorded hook hash.
- `hooks.redacted.json`: the exact R4 hook registry structure with only the former profile path in command strings replaced by `<redacted-profile>`. The original registry hash matches the receipt's `hooksJson.postSha256` (`460fbea1b1d5d131dff3beb253a9819575758c3860e5f8e08167681260dde1a7`).
- `20260816_225304_646-receipt.redacted.json`: the R4 change receipt with former-profile paths replaced by `<redacted-profile>`; its technical revision, hash, and validation fields are preserved.

The receipt records `APPLIED_LOCAL_VALIDATION_PASSED_RUNTIME_DISCOVERY_NOT_TESTED`; skill and hook discovery, automatic activation, and behavioral compliance were not tested. It says the R4 change normalized all eight identifiers and added a mandatory-if-applicable protocol hook without changing semantic skill bodies or descriptions.

The recovered `GEMINI.md` labels itself an experimental baseline and **NOT A PROMOTION CANDIDATE**. Do not treat its presence or receipt validation as evidence of promotion or runtime effectiveness. It is not installed by default; the installer requires an explicit opt-in to install it for a controlled trial. The later FG-v1 forced-loading hook is preserved separately under [`../../historical-hooks/`](../../historical-hooks/README.md) and is the hook used by the current standalone installer.
