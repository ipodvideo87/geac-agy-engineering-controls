[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BackupPath,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Usage: .\Restore-GEAC-X1.ps1 -BackupPath '<BACKUP_PATH printed by installer>'

function Resolve-X1TargetPath {
    param([Parameter(Mandatory = $true)][string]$Target)
    if (-not $Target.StartsWith('.gemini/')) {
        throw "Refusing target outside .gemini: $Target"
    }
    $relative = ($Target -split '/') -join [IO.Path]::DirectorySeparatorChar
    return (Join-Path $HOME $relative)
}

$BackupPath = (Resolve-Path -LiteralPath $BackupPath).Path
$statePath = Join-Path $BackupPath 'backup-state.json'
$manifestPath = Join-Path $BackupPath 'x1-payload-manifest.json'
if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
    throw "backup-state.json not found: $statePath"
}
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "X1 manifest copy not found in backup: $manifestPath"
}

$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
if ($state.backup_for_contract -ne 'GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE') {
    throw "Backup was not created for the X1 experimental baseline."
}

foreach ($item in $state.files) {
    $target = Resolve-X1TargetPath -Target $item.target
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $current = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
        $allowed = @(([string]$item.x1_sha256).ToLowerInvariant())
        if ([bool]$item.existed -and $null -ne $item.original_sha256) {
            $allowed += ([string]$item.original_sha256).ToLowerInvariant()
        }
        if (($current -notin $allowed) -and (-not $Force)) {
            throw "Managed file changed after X1 install: $($item.target). Re-run with -Force only if you intend to discard that change."
        }
    }
    if ([bool]$item.existed) {
        $backupFile = Join-Path $BackupPath (([string]$item.backup_file -split '/') -join [IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) {
            throw "Original backup file missing: $backupFile"
        }
        $backupSha = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($backupSha -ne ([string]$item.original_sha256).ToLowerInvariant()) {
            throw "Original backup hash mismatch: $backupFile"
        }
    }
}

$skillStates = @($state.files | Where-Object { $_.target -ne '.gemini/GEMINI.md' })
$geminiStates = @($state.files | Where-Object { $_.target -eq '.gemini/GEMINI.md' })

foreach ($item in $skillStates) {
    $target = Resolve-X1TargetPath -Target $item.target
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        Remove-Item -LiteralPath $target -Force
    }
    if ([bool]$item.existed) {
        $backupFile = Join-Path $BackupPath (([string]$item.backup_file -split '/') -join [IO.Path]::DirectorySeparatorChar)
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath $backupFile -Destination $target -Force
    }
}

# Restore GEMINI.md last
foreach ($item in $geminiStates) {
    $target = Resolve-X1TargetPath -Target $item.target
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        Remove-Item -LiteralPath $target -Force
    }
    if ([bool]$item.existed) {
        $backupFile = Join-Path $BackupPath (([string]$item.backup_file -split '/') -join [IO.Path]::DirectorySeparatorChar)
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -LiteralPath $backupFile -Destination $target -Force
    }
}

foreach ($item in $state.files) {
    $target = Resolve-X1TargetPath -Target $item.target
    if ([bool]$item.existed) {
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            throw "RESTORE_VERIFY_MISSING: $($item.target)"
        }
        $restoredSha = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($restoredSha -ne ([string]$item.original_sha256).ToLowerInvariant()) {
            throw "RESTORE_VERIFY_HASH_MISMATCH: $($item.target)"
        }
    }
    else {
        if (Test-Path -LiteralPath $target -PathType Leaf) {
            throw "RESTORE_VERIFY_EXPECTED_ABSENT: $($item.target)"
        }
    }
}

Write-Host "GEAC X1 restore PASSED. Exact pre-X1 managed-file state restored from: $BackupPath"
