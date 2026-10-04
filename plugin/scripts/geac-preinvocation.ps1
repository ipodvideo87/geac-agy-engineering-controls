[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$payloadPath = Join-Path $PSScriptRoot 'geac-auto-state-output.json'
if (-not (Test-Path -LiteralPath $payloadPath -PathType Leaf)) {
    throw "The generated all-skills payload is missing: $payloadPath"
}

$json = Get-Content -LiteralPath $payloadPath -Raw -Encoding UTF8
$payload = $json | ConvertFrom-Json
$message = [string]$payload.injectSteps[0].ephemeralMessage
$loadedSkills = ([regex]::Matches($message, '(?m)^===== UNCONDITIONALLY LOADED SKILL: ')).Count
if ($loadedSkills -ne 8 -or $message -notmatch 'GEAC_AUTO_STATE=FORCED_ON_UNCONDITIONALLY') {
    throw "Expected the generated payload to force-load exactly eight GEAC skills; found $loadedSkills."
}

# AGY reads hook output as UTF-8 JSON. Write directly to stdout to avoid
# PowerShell formatting and the host's legacy console encoding.
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::Out.Write($json)
