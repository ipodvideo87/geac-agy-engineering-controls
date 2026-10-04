[CmdletBinding()]
param(
    [string]$BackupRoot = (Join-Path $HOME '.gemini\geac-backups\X1')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PackageRoot = $PSScriptRoot
$ManifestPath = Join-Path $PackageRoot 'X1-PAYLOAD-MANIFEST.json'
$ContractId = 'GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE'

function Resolve-X1TargetPath {
    param([Parameter(Mandatory = $true)][string]$Target)
    if (-not $Target.StartsWith('.gemini/')) {
        throw "Refusing target outside .gemini: $Target"
    }
    $relative = ($Target -split '/') -join [IO.Path]::DirectorySeparatorChar
    return (Join-Path $HOME $relative)
}

function Test-InstalledPayload {
    param([Parameter(Mandatory = $true)]$Manifest)
    foreach ($entry in $Manifest.files) {
        $targetPath = Resolve-X1TargetPath -Target $entry.target
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            throw "MISSING installed target: $($entry.target)"
        }
        $actual = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash.ToLowerInvariant()
        $expected = ([string]$entry.sha256).ToLowerInvariant()
        if ($actual -ne $expected) {
            throw "HASH_MISMATCH for $($entry.target): expected=$expected actual=$actual"
        }
    }
}

function Restore-X1BackupState {
    param(
        [Parameter(Mandatory = $true)]$State,
        [Parameter(Mandatory = $true)][string]$BackupPath
    )

    $skillStates = @($State.files | Where-Object { $_.target -ne '.gemini/GEMINI.md' })
    $geminiStates = @($State.files | Where-Object { $_.target -eq '.gemini/GEMINI.md' })

    foreach ($item in @($skillStates + $geminiStates)) {
        $targetPath = Resolve-X1TargetPath -Target $item.target
        if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
            Remove-Item -LiteralPath $targetPath -Force
        }
        if ([bool]$item.existed) {
            $backupFile = Join-Path $BackupPath ([string]$item.backup_file)
            if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) {
                throw "Backup file missing during rollback: $backupFile"
            }
            $actualBackupHash = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash.ToLowerInvariant()
            if ($actualBackupHash -ne ([string]$item.original_sha256).ToLowerInvariant()) {
                throw "Backup hash mismatch during rollback: $backupFile"
            }
            $parent = Split-Path -Parent $targetPath
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
            Copy-Item -LiteralPath $backupFile -Destination $targetPath -Force
        }
    }
}

if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
    throw "Manifest not found: $ManifestPath"
}
$Manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
if ($Manifest.contract_id -ne $ContractId) {
    throw "Unexpected contract ID in manifest: $($Manifest.contract_id)"
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
$BackupPath = Join-Path $BackupRoot $timestamp
if (Test-Path -LiteralPath $BackupPath) {
    throw "Backup directory already exists; refusing overwrite: $BackupPath"
}
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

$manifestCopy = Join-Path $BackupPath 'x1-payload-manifest.json'
Copy-Item -LiteralPath $ManifestPath -Destination $manifestCopy
$manifestSha = (Get-FileHash -LiteralPath $ManifestPath -Algorithm SHA256).Hash.ToLowerInvariant()

$backupEntries = @()
foreach ($entry in $Manifest.files) {
    $targetPath = Resolve-X1TargetPath -Target $entry.target
    $existed = Test-Path -LiteralPath $targetPath -PathType Leaf
    $backupRel = ('original/' + [string]$entry.target)
    $backupFile = Join-Path $BackupPath (($backupRel -split '/') -join [IO.Path]::DirectorySeparatorChar)
    $originalSha = $null
    $originalBytes = $null

    if ($existed) {
        $backupParent = Split-Path -Parent $backupFile
        New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
        $originalSha = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash.ToLowerInvariant()
        $originalBytes = (Get-Item -LiteralPath $targetPath).Length
        Copy-Item -LiteralPath $targetPath -Destination $backupFile
        $backupSha = (Get-FileHash -LiteralPath $backupFile -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($backupSha -ne $originalSha) {
            throw "Backup copy hash mismatch: $($entry.target)"
        }
    }

    $backupEntries += [pscustomobject]@{
        target = [string]$entry.target
        package_path = [string]$entry.package_path
        existed = [bool]$existed
        backup_file = $backupRel
        original_sha256 = $originalSha
        original_bytes = $originalBytes
        x1_sha256 = ([string]$entry.sha256).ToLowerInvariant()
    }
}

$backupState = [pscustomobject]@{
    backup_for_contract = $ContractId
    created_at = (Get-Date).ToString('o')
    home = $HOME
    package_manifest_sha256 = $manifestSha
    files = $backupEntries
}
$backupStatePath = Join-Path $BackupPath 'backup-state.json'
$backupState | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $backupStatePath -Encoding UTF8

try {
    # Install skills first
    foreach ($entry in @($Manifest.files | Where-Object { $_.target -ne '.gemini/GEMINI.md' })) {
        $source = Join-Path $PackageRoot (([string]$entry.package_path -split '/') -join [IO.Path]::DirectorySeparatorChar)
        $target = Resolve-X1TargetPath -Target $entry.target
        $parent = Split-Path -Parent $target
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $target -Force
    }

    # Install GEMINI.md last
    $geminiEntry = @($Manifest.files | Where-Object { $_.target -eq '.gemini/GEMINI.md' })
    if ($geminiEntry.Count -ne 1) {
        throw "Manifest must contain exactly one GEMINI.md entry."
    }
    $geminiSource = Join-Path $PackageRoot (([string]$geminiEntry[0].package_path -split '/') -join [IO.Path]::DirectorySeparatorChar)
    $geminiTarget = Resolve-X1TargetPath -Target $geminiEntry[0].target
    New-Item -ItemType Directory -Path (Split-Path -Parent $geminiTarget) -Force | Out-Null
    Copy-Item -LiteralPath $geminiSource -Destination $geminiTarget -Force

    Test-InstalledPayload -Manifest $Manifest
}
catch {
    Write-Warning "X1 installation failed; attempting automatic rollback from $BackupPath"
    $state = Get-Content -LiteralPath $backupStatePath -Raw | ConvertFrom-Json
    Restore-X1BackupState -State $state -BackupPath $BackupPath
    throw
}

Write-Host ''
Write-Host "GEAC X1 installed and byte-verified: $ContractId"
Write-Host "BACKUP_PATH=$BackupPath"
Write-Host "Do not delete this backup until X1 testing is complete."
Write-Host "Next: run .\Verify-GEAC-X1.ps1, then follow experiments\FIRST-RUN-SANITY-001.md"
