[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$packageRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$profileRoot = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.gemini'
$sourceSkills = Join-Path $packageRoot 'payload\skills'
$sourceRequiredGate = Join-Path $packageRoot 'reference\source\historical-hooks\geac-required-gate.fg-v1.ps1'
$sourceClaimAdmission = Join-Path $packageRoot 'reference\source\historical-hooks\geac-x1-r2-claim-admission.ps1'
$expectedClaimAdmissionSHA256 = '927f307b30a56a33f88cc7fb23d2651a5047a16155e82ddce728112fe5d70b6d'

function Assert-SameFile {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target
    )
    if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) { throw "Missing installed file: $Target" }
    $sourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash.ToLowerInvariant()
    $targetHash = (Get-FileHash -LiteralPath $Target -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($sourceHash -ne $targetHash) { throw "Installed file hash differs from package source: $Target" }
}

$globalGeminiPath = Join-Path $profileRoot 'GEMINI.md'
if (Test-Path -LiteralPath $globalGeminiPath -PathType Leaf) {
    $globalGemini = [IO.File]::ReadAllText($globalGeminiPath)
    if ($globalGemini.Contains('GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE')) {
        throw 'The X1 experimental GEMINI.md must not be active with this setup.'
    }
}

$skillDirectories = @(Get-ChildItem -LiteralPath $sourceSkills -Directory | Sort-Object Name)
if ($skillDirectories.Count -ne 8) { throw "Expected eight package skills; found $($skillDirectories.Count)." }
foreach ($directory in $skillDirectories) {
    if ($directory.Name -notlike 'required-gate-*') { throw "Invalid required-gate skill name: $($directory.Name)" }
    Assert-SameFile -Source (Join-Path $directory.FullName 'SKILL.md') -Target (Join-Path $profileRoot ('antigravity-cli\skills\' + $directory.Name + '\SKILL.md'))
}

$requiredGateTarget = Join-Path $profileRoot 'config\hooks\geac-required-gate.ps1'
$claimAdmissionTarget = Join-Path $profileRoot 'config\hooks\geac-x1-r2-claim-admission.ps1'
$obsoleteReminderTarget = Join-Path $profileRoot 'config\hooks\geac-claim-admission-reminder.ps1'
Assert-SameFile -Source $sourceRequiredGate -Target $requiredGateTarget
Assert-SameFile -Source $sourceClaimAdmission -Target $claimAdmissionTarget
if ((Get-FileHash -LiteralPath $sourceClaimAdmission -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedClaimAdmissionSHA256) {
    throw 'Recovered R2 claim-admission source does not match its transcript-recorded SHA-256.'
}
if (Test-Path -LiteralPath $obsoleteReminderTarget -PathType Leaf) {
    throw "Superseded reminder reconstruction remains installed: $obsoleteReminderTarget"
}

$registry = Get-Content -LiteralPath (Join-Path $profileRoot 'config\hooks.json') -Raw | ConvertFrom-Json
if ($null -ne $registry.PSObject.Properties['geac-claim-admission-reminder']) {
    throw 'Superseded claim-admission reminder hook is still registered.'
}
foreach ($name in @('geac-required-gate', 'geac-x1-r2-claim-admission')) {
    $hook = $registry.PSObject.Properties[$name]
    if ($null -eq $hook) { throw "Hook is not registered: $name" }
    if (-not [bool]$hook.Value.enabled) { throw "Hook is disabled: $name" }
    if (@($hook.Value.PreInvocation).Count -ne 1) { throw "Expected one PreInvocation handler: $name" }
}
if ([string]$registry.'geac-required-gate'.PreInvocation[0].command -notlike ('*' + $requiredGateTarget + '*')) {
    throw 'FG-v1 registration does not point to the installed script.'
}
if ([string]$registry.'geac-x1-r2-claim-admission'.PreInvocation[0].command -notlike ('*' + $claimAdmissionTarget + '*')) {
    throw 'R2 claim-admission registration does not point to the installed script.'
}
if ([string]$registry.'geac-x1-r2-claim-admission'.PreInvocation[0].command -notlike '*-NoLogo -NoProfile -NonInteractive*') {
    throw 'R2 claim-admission registration is missing the recovered PowerShell flags.'
}
if ($null -ne $registry.'geac-x1-r2-claim-admission'.PreInvocation[0].PSObject.Properties['timeout']) {
    throw 'R2 claim-admission registration unexpectedly adds a timeout not present in the recovered configuration.'
}

$raw = '{}' | & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $requiredGateTarget
if ($LASTEXITCODE -ne 0) { throw "FG-v1 direct invocation failed: exit=$LASTEXITCODE" }
$payload = $raw | ConvertFrom-Json
$message = [string]$payload.injectSteps[0].ephemeralMessage
$names = @(
    [regex]::Matches($message, '(?m)^Canonical-Name:\s+(required-gate-[^\r\n]+)$') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique
)
if ($names.Count -ne 8) { throw "FG-v1 emitted $($names.Count) unique names; expected 8." }
$newline = [string][char]10
$normalizedMessage = [regex]::Replace($message, "\r\n?", $newline)
foreach ($directory in $skillDirectories) {
    $sourceText = [IO.File]::ReadAllText((Join-Path $directory.FullName 'SKILL.md'), [Text.Encoding]::UTF8)
    $normalizedSource = [regex]::Replace($sourceText, "\r\n?", $newline).TrimEnd([char[]]@([char]13, [char]10))
    if (-not $normalizedMessage.Contains($normalizedSource)) {
        throw "FG-v1 payload omitted the complete skill body: $($directory.Name)"
    }
}

$rawClaimAdmission = '{}' | & powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $claimAdmissionTarget
if ($LASTEXITCODE -ne 0) { throw "R2 claim-admission hook invocation failed: exit=$LASTEXITCODE" }
$claimPayload = $rawClaimAdmission | ConvertFrom-Json
$claimMessage = [string]$claimPayload.injectSteps[0].ephemeralMessage
if ($claimMessage -notmatch 'GEAC CLAIM-ADMISSION INTERCEPT' -or
    $claimMessage -notmatch 'SOURCE' -or
    $claimMessage -notmatch 'STRENGTH' -or
    $claimMessage -notmatch 'SEMANTIC OWNER' -or
    $claimMessage -notmatch 'FALLBACK') {
    throw 'R2 claim-admission hook did not return the recovered claim reminder.'
}

Write-Output 'Standalone GEAC setup verified.'
Write-Output 'R3 v2 skills: 8/8 installed with matching names and hashes.'
Write-Output 'FG-v1: registered, enabled, eight unique names, full bodies injected (8/8).'
Write-Output 'R2 claim hook: transcript SHA-256 matched; registered PreInvocation-only and returns its transient message.'
Write-Output 'These checks verify files and hook payloads, not model behavior.'
