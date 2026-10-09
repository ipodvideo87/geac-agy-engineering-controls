$ErrorActionPreference = 'Stop'

# Antigravity PreInvocation supplies JSON on stdin.
# X1-R2 intentionally consumes the invocation metadata without using it to
# inspect, modify, authorize, or infer anything about the active project.
[Console]::In.ReadToEnd() | Out-Null

$message = @"
GEAC CLAIM-ADMISSION INTERCEPT

Before emitting any material case-specific engineering claim:

1. SOURCE
Identify the exact evidence or source relation that supports the proposed wording.

2. STRENGTH
Do not add a stronger fact, relation, scope, mechanism, causality, identity, provenance, criterion, certainty, or necessity unless that stronger relation is established.

3. SEMANTIC OWNER
If the proposed wording uses or implies a controlled GEAC state or relation, it must satisfy the admission rules of its existing semantic owner before use.

4. FALLBACK
If the required support or semantic-owner admission is missing, NARROW or REJECT the candidate claim. Preserve the strongest relation actually established.

Ordinary reasoning may propose a stronger explanation, conclusion, or action. Proposal alone does not establish, authorize, or require it.
"@

$output = [ordered]@{
    injectSteps = @(
        [ordered]@{
            ephemeralMessage = $message.Trim()
        }
    )
}

$output | ConvertTo-Json -Depth 6 -Compress