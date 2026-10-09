[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$BackupPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resolvedBackup = [IO.Path]::GetFullPath($BackupPath)
$statePath = Join-Path $resolvedBackup 'restore-state.json'
if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
    throw "Restore state not found: $statePath"
}
$state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
$profileRoot = [IO.Path]::GetFullPath($state.ProfileRoot)
$expectedProfile = [IO.Path]::GetFullPath((Join-Path ([Environment]::GetFolderPath('UserProfile')) '.gemini'))
if (-not $profileRoot.Equals($expectedProfile, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Backup belongs to a different profile: $profileRoot"
}

foreach ($entry in @($state.Files | Sort-Object { $_.RelativePath -eq 'config\hooks.json' })) {
    $destination = Join-Path $profileRoot $entry.RelativePath
    if ([bool]$entry.RemovedAfterInstall) {
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            throw "Retired file reappeared after install; refusing ambiguous restore: $destination"
        }
        continue
    }
    if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
        throw "Installed file is missing; refusing ambiguous restore: $destination"
    }
    $currentHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($currentHash -ne ([string]$entry.InstalledSHA256).ToLowerInvariant()) {
        throw "Installed file changed after setup; refusing to overwrite it: $destination"
    }
}

foreach ($entry in @($state.Files | Sort-Object { $_.RelativePath -eq 'config\hooks.json' })) {
    $destination = Join-Path $profileRoot $entry.RelativePath
    if ([bool]$entry.Existed) {
        $backupFile = Join-Path $resolvedBackup $entry.BackupRelativePath
        if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) { throw "Backup file missing: $backupFile" }
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath $backupFile -Destination $destination -Force
    }
    else {
        if (Test-Path -LiteralPath $destination -PathType Leaf) { Remove-Item -LiteralPath $destination }
    }
}

Write-Output "Restored standalone GEAC targets from $resolvedBackup"
Write-Output 'Files created by the installation were removed; prior files were restored from backup.'
