# Recovered standalone hooks

This directory contains the two standalone PowerShell hooks recovered from the full conversation export. The installer installs both as enabled global `PreInvocation` hooks. They have separate jobs: FG-v1 loads the required skills; R2 injects claim-admission guidance.

## FG-v1 forced-skill hook

Source: [`geac-required-gate.fg-v1.ps1`](geac-required-gate.fg-v1.ps1)

The recorded setup uses hook name `geac-required-gate`, event `PreInvocation`, and a 10-second timeout. It scans skill folders for canonical names beginning `required-gate-`, reads their full `SKILL.md` bodies, and injects them into an ephemeral message before each model invocation. The current package verifier confirms that the installed hook emits all eight packaged skill bodies. Presence in context does not guarantee that the model follows them.

The source is transcript-recovered, but its original bytes were not independently matched to a historical on-disk hash. The conversation's original literal body check returned 0/8; the current newline-normalized verifier passes 8/8 for the packaged source and skills.

## R2 claim-admission hook

Source: [`geac-x1-r2-claim-admission.ps1`](geac-x1-r2-claim-admission.ps1)

The exact 36 numbered lines were extracted from the full conversation export. The recovered bytes match the recorded file size of 1,317 bytes and SHA-256 `927f307b30a56a33f88cc7fb23d2651a5047a16155e82ddce728112fe5d70b6d`.

The script consumes the `PreInvocation` JSON and injects a reminder to identify source, avoid strengthening claims beyond evidence, consult semantic owners, and narrow or reject unsupported claims. It does not inspect generated output or mechanically validate claims.

The later exact `hooks.json` shown in the transcript registers this hook for `PreInvocation` only. `SessionStart`, `PostInvocation`, `Stop`, `PreToolUse`, and `PostToolUse` are null. An earlier discussion described five lifecycle events; the later configuration evidence corrected that description.

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
