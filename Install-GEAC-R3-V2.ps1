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
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$backupRoot = Join-Path $profileRoot ('geac-backups\GEAC-R3-V2-FGv1\' + $timestamp)
$globalSkillRoot = Join-Path $profileRoot 'antigravity-cli\skills'
$hookRegistryPath = Join-Path $profileRoot 'config\hooks.json'
$pluginConfigPath = Join-Path $profileRoot 'config\config.json'

foreach ($source in @($sourceRequiredGate, $sourceClaimAdmission)) {
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Package source missing: $source" }
}
$claimAdmissionSHA256 = (Get-FileHash -LiteralPath $sourceClaimAdmission -Algorithm SHA256).Hash.ToLowerInvariant()
if ($claimAdmissionSHA256 -ne $expectedClaimAdmissionSHA256) {
    throw "Recovered R2 claim-admission source hash mismatch: $claimAdmissionSHA256"
}

$globalGeminiPath = Join-Path $profileRoot 'GEMINI.md'
if (Test-Path -LiteralPath $globalGeminiPath -PathType Leaf) {
    $globalGemini = [IO.File]::ReadAllText($globalGeminiPath)
    if ($globalGemini.Contains('GEAC-2026-08-15-X1-EXPERIMENTAL-BASELINE')) {
        throw 'The X1 experimental GEMINI.md is not part of this setup. Move it out of the global profile before installing.'
    }
}

$skillDirectories = @(Get-ChildItem -LiteralPath $sourceSkills -Directory | Sort-Object Name)
if ($skillDirectories.Count -ne 8) { throw "Expected exactly eight source skills; found $($skillDirectories.Count)." }

if (Test-Path -LiteralPath $pluginConfigPath -PathType Leaf) {
    $pluginConfig = Get-Content -LiteralPath $pluginConfigPath -Raw | ConvertFrom-Json
    $plugins = $pluginConfig.plugins
    if ($null -ne $plugins -and $null -ne $plugins.PSObject.Properties['geac-x1-r1-engineering-controls'] -and
        [bool]$plugins.'geac-x1-r1-engineering-controls'.enabled) {
        throw 'The GEAC plugin is enabled. Disable or uninstall it before installing the standalone setup.'
    }
}

$targets = [Collections.Generic.List[object]]::new()
foreach ($directory in $skillDirectories) {
    $skillFile = Join-Path $directory.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) { throw "Skill file missing: $skillFile" }
    $frontmatter = Get-Content -LiteralPath $skillFile -TotalCount 12
    if (($frontmatter -join [Environment]::NewLine) -notmatch ('(?m)^name:\s*' + [regex]::Escape($directory.Name) + '\s*$') -or
        $directory.Name -notlike 'required-gate-*') {
        throw "Skill folder/name mismatch or missing required-gate prefix: $($directory.Name)"
    }
    $targets.Add([pscustomobject]@{
        Source = $skillFile
        RelativePath = 'antigravity-cli\skills\' + $directory.Name + '\SKILL.md'
        RemoveAfterInstall = $false
    })
}
$targets.Add([pscustomobject]@{
    Source = $sourceRequiredGate
    RelativePath = 'config\hooks\geac-required-gate.ps1'
    RemoveAfterInstall = $false
})
$targets.Add([pscustomobject]@{
    Source = $sourceClaimAdmission
    RelativePath = 'config\hooks\geac-x1-r2-claim-admission.ps1'
    RemoveAfterInstall = $false
})
$targets.Add([pscustomobject]@{
    Source = $null
    RelativePath = 'config\hooks\geac-claim-admission-reminder.ps1'
    RemoveAfterInstall = $true
})

New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
$backupEntries = [Collections.Generic.List[object]]::new()
foreach ($target in $targets) {
    $destination = Join-Path $profileRoot $target.RelativePath
    $existed = Test-Path -LiteralPath $destination -PathType Leaf
    $backupRelative = 'original\' + $target.RelativePath
    $backupFile = Join-Path $backupRoot $backupRelative
    if ($existed) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $backupFile) -Force | Out-Null
        Copy-Item -LiteralPath $destination -Destination $backupFile
    }
    $backupEntries.Add([pscustomobject]@{
        RelativePath = $target.RelativePath
        Existed = $existed
        BackupRelativePath = $backupRelative
        InstalledSHA256 = $null
        RemovedAfterInstall = [bool]$target.RemoveAfterInstall
    })
}

$registryExisted = Test-Path -LiteralPath $hookRegistryPath -PathType Leaf
$registryBackupRelative = 'original\config\hooks.json'
if ($registryExisted) {
    $registryBackup = Join-Path $backupRoot $registryBackupRelative
    New-Item -ItemType Directory -Path (Split-Path -Parent $registryBackup) -Force | Out-Null
    Copy-Item -LiteralPath $hookRegistryPath -Destination $registryBackup
}
$backupEntries.Add([pscustomobject]@{
    RelativePath = 'config\hooks.json'
    Existed = $registryExisted
    BackupRelativePath = $registryBackupRelative
    InstalledSHA256 = $null
    RemovedAfterInstall = $false
})
$backupState = [ordered]@{
    CreatedAt = (Get-Date).ToString('o')
    PackageRoot = $packageRoot
    ProfileRoot = $profileRoot
    Files = @($backupEntries)
}
[IO.File]::WriteAllText((Join-Path $backupRoot 'restore-state.json'),
    ($backupState | ConvertTo-Json -Depth 8) + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))

try {
    foreach ($target in $targets) {
        $destination = Join-Path $profileRoot $target.RelativePath
        if ($target.RemoveAfterInstall) {
            if (Test-Path -LiteralPath $destination -PathType Leaf) { Remove-Item -LiteralPath $destination -Force }
            continue
        }
        New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
        Copy-Item -LiteralPath $target.Source -Destination $destination -Force
    }

    if ($registryExisted) {
        $registry = Get-Content -LiteralPath $hookRegistryPath -Raw | ConvertFrom-Json
    }
    else {
        $registry = [pscustomobject]@{}
    }

    if ($null -ne $registry.PSObject.Properties['geac-claim-admission-reminder']) {
        $registry.PSObject.Properties.Remove('geac-claim-admission-reminder')
    }
    $hookDefinitions = @(
        [pscustomobject]@{
            Name = 'geac-required-gate'
            RelativePath = 'config\hooks\geac-required-gate.ps1'
            PowerShellFlags = '-NoProfile'
            Timeout = 10
        },
        [pscustomobject]@{
            Name = 'geac-x1-r2-claim-admission'
            RelativePath = 'config\hooks\geac-x1-r2-claim-admission.ps1'
            PowerShellFlags = '-NoLogo -NoProfile -NonInteractive'
            Timeout = $null
        }
    )
    foreach ($hook in $hookDefinitions) {
        if ($null -ne $registry.PSObject.Properties[$hook.Name]) {
            $registry.PSObject.Properties.Remove($hook.Name)
        }
        $hookPath = Join-Path $profileRoot $hook.RelativePath
        $command = 'powershell.exe ' + $hook.PowerShellFlags + ' -ExecutionPolicy Bypass -File "' + $hookPath + '"'
        $handler = [ordered]@{
            type = 'command'
            command = $command
        }
        if ($null -ne $hook.Timeout) { $handler['timeout'] = $hook.Timeout }
        $value = [pscustomobject]@{
            enabled = $true
            PreInvocation = @([pscustomobject]$handler)
        }
        $registry | Add-Member -MemberType NoteProperty -Name $hook.Name -Value $value
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $hookRegistryPath) -Force | Out-Null
    [IO.File]::WriteAllText($hookRegistryPath, ($registry | ConvertTo-Json -Depth 20) + [Environment]::NewLine,
        [Text.UTF8Encoding]::new($false))

    $statePath = Join-Path $backupRoot 'restore-state.json'
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    foreach ($entry in $state.Files) {
        $installedPath = Join-Path $profileRoot $entry.RelativePath
        if ([bool]$entry.RemovedAfterInstall) {
            if (Test-Path -LiteralPath $installedPath -PathType Leaf) {
                throw "Retired file remains after install: $installedPath"
            }
            $entry.InstalledSHA256 = $null
        }
        else {
            $entry.InstalledSHA256 = (Get-FileHash -LiteralPath $installedPath -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    }
    [IO.File]::WriteAllText($statePath, ($state | ConvertTo-Json -Depth 8) + [Environment]::NewLine,
        [Text.UTF8Encoding]::new($false))

    & (Join-Path $packageRoot 'Verify-GEAC-R3-V2.ps1')
    Write-Output 'Installed standalone GEAC R3 v2 skills-and-hooks setup.'
    Write-Output "Backup: $backupRoot"
    Write-Output 'The transcript-recovered R2 claim-admission hook is installed for PreInvocation only.'
}
catch {
    foreach ($entry in @($backupEntries | Sort-Object { $_.RelativePath -eq 'config\hooks.json' })) {
        $destination = Join-Path $profileRoot $entry.RelativePath
        if ($entry.Existed) {
            $backupFile = Join-Path $backupRoot $entry.BackupRelativePath
            if (Test-Path -LiteralPath $backupFile -PathType Leaf) {
                New-Item -ItemType Directory -Path (Split-Path -Parent $destination) -Force | Out-Null
                Copy-Item -LiteralPath $backupFile -Destination $destination -Force
            }
        }
        elseif (Test-Path -LiteralPath $destination -PathType Leaf) {
            Remove-Item -LiteralPath $destination
        }
    }
    throw
}
