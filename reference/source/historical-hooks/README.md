# Recovered standalone hooks

This directory contains the two standalone PowerShell hooks recovered byte-for-byte from the former profile and corroborated by the full conversation export. The installer explicitly registers both as enabled global `PreInvocation` hooks. They have separate jobs: FG-v1 loads the required skills; R2 injects claim-admission guidance.

## FG-v1 forced-skill hook

Source: [`geac-required-gate.fg-v1.ps1`](geac-required-gate.fg-v1.ps1)

The recorded setup uses hook name `geac-required-gate`, event `PreInvocation`, and a 10-second timeout. It scans skill folders for canonical names beginning `required-gate-`, reads their full `SKILL.md` bodies, and injects them into an ephemeral message before each model invocation. The current package verifier confirms that the installed hook emits all eight packaged skill bodies. Presence in context does not guarantee that the model follows them.

The active FG-v1 file was recovered from the former profile and matches the packaged source byte-for-byte: 6,737 bytes, SHA-256 `d9aec018798b0b2eeb04f13bd738327839afb643900e9e294a57fe1d03ad2f2d`. It postdates and replaces the R4 protocol hook preserved in [`../historical-setups/X1-R4/hooks/geac-required-gate.r4-protocol-hook.ps1`](../historical-setups/X1-R4/hooks/geac-required-gate.r4-protocol-hook.ps1), whose recorded SHA-256 is `1965d3be9814ad3e0e2c1ea204e946b6e55a814fd4f9d702e1a2827d5939bdab`. The conversation's original literal body check returned 0/8; a later newline-normalized verifier passed 8/8 for the packaged source and skills. The byte match establishes source identity, not runtime loading or model compliance.

## R2 claim-admission hook

Source: [`geac-x1-r2-claim-admission.ps1`](geac-x1-r2-claim-admission.ps1)

The exact 36 numbered lines were extracted from the full conversation export. The recovered bytes match the recorded file size of 1,317 bytes and SHA-256 `927f307b30a56a33f88cc7fb23d2651a5047a16155e82ddce728112fe5d70b6d`.

The script consumes the `PreInvocation` JSON and injects a reminder to identify source, avoid strengthening claims beyond evidence, consult semantic owners, and narrow or reject unsupported claims. It does not inspect generated output or mechanically validate claims.

The exact X1-R4 registry snapshot is preserved in redacted form at [`../historical-setups/X1-R4/hooks.redacted.json`](../historical-setups/X1-R4/hooks.redacted.json). Its R2 entry registers `PreInvocation` and omits the optional `enabled` property; current [Antigravity hook documentation](https://antigravity.google/docs/hooks) says the default is enabled. The R4 forced-gate entry explicitly sets `enabled: true`. `SessionStart`, `PostInvocation`, `Stop`, `PreToolUse`, and `PostToolUse` are null. An earlier discussion described five lifecycle events; the later configuration evidence corrected that description. The standalone installer explicitly writes `enabled: true` for both hooks.

The original command was:

```text
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "<profile>\\.gemini\\config\\hooks\\geac-x1-r2-claim-admission.ps1"
```

It had no timeout property in the recorded configuration. The installer uses the same PowerShell flags, substitutes the installing profile path, and registers only `PreInvocation`.

## How the hooks fit together

```text
PreInvocation
├── geac-required-gate
│   └── inject all `required-gate-*` skill bodies
└── geac-x1-r2-claim-admission
    └── inject claim-admission reminder
```

The transcript does not establish an execution-order guarantee between separately registered hooks. Neither hook mechanically enforces the other's behavior. The R2 message is a model instruction; FG-v1 is a deterministic skill-text loader.
