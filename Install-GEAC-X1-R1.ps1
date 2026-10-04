[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PackageRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$PluginName = 'geac-x1-r1-engineering-controls'
$PluginSource = Join-Path $PackageRoot 'plugin'
$PackageManifestPath = Join-Path $PackageRoot 'PACKAGE-MANIFEST.json'
$CommonManifestPath = Join-Path $PackageRoot 'PLUGIN-SHA256.txt'
$PluginPaths = @(
    (Join-Path $HOME ('.gemini\config\plugins\' + $PluginName)),
    (Join-Path $HOME ('.gemini\antigravity-cli\plugins\' + $PluginName))
)

function Resolve-AgyCli {
    $cmd = Get-Command 'agy' -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { return $cmd.Source }
    $candidate = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
    if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    throw 'AGY CLI was not found. Install Antigravity CLI 1.2.7 or later and make agy available on PATH.'
}

function Assert-PackageIntegrity {
    $manifest = Get-Content -LiteralPath $PackageManifestPath -Raw | ConvertFrom-Json
    $listed = @{}
    foreach ($entry in $manifest.files) {
        $rel = [string]$entry.path
        if ([IO.Path]::IsPathRooted($rel) -or $rel -match '(^|[\\/])\.\.([\\/]|$)') { throw "Unsafe manifest path: $rel" }
        $path = Join-Path $PackageRoot ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
        $full = [IO.Path]::GetFullPath($path)
        if (-not $full.StartsWith($PackageRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw "Manifest path escapes package root: $rel" }
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { throw "Package file missing: $rel" }
        $actual = (Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -ne ([string]$entry.sha256).ToLowerInvariant()) { throw "Package hash mismatch: $rel" }
        $listed[$rel] = $true
    }
    $packageChecksumPath = Join-Path $PackageRoot 'PACKAGE-SHA256.txt'
    $gitMetadataPrefix = [IO.Path]::GetFullPath((Join-Path $PackageRoot '.git')) + [IO.Path]::DirectorySeparatorChar
    $pythonCacheSegment = [IO.Path]::DirectorySeparatorChar + '__pycache__' + [IO.Path]::DirectorySeparatorChar
    $actualFiles = @(Get-ChildItem -LiteralPath $PackageRoot -Recurse -File | Where-Object {
        $_.FullName -ne $PackageManifestPath -and
        $_.FullName -ne $packageChecksumPath -and
        -not $_.FullName.StartsWith($gitMetadataPrefix, [StringComparison]::OrdinalIgnoreCase) -and
        -not $_.FullName.Contains($pythonCacheSegment)
    })
    if ($actualFiles.Count -ne $listed.Count) { throw "Package file count mismatch: manifest=$($listed.Count) disk=$($actualFiles.Count)" }
    foreach ($file in $actualFiles) {
        $rel = $file.FullName.Substring($PackageRoot.Length).TrimStart('\','/').Replace('\','/')
        if (-not $listed.ContainsKey($rel)) { throw "Unmanifested package file: $rel" }
    }
}

function Get-AgyVersion {
    param([string]$Agy)
    $raw = (& $Agy --version | Out-String).Trim()
    $parsed = [version]'0.0'
    if (-not [version]::TryParse($raw, [ref]$parsed)) { throw "Could not parse AGY CLI version output: $raw" }
    if ($parsed -lt [version]'1.2.7') { throw "AGY CLI 1.2.7 or later is required; found $raw" }
    return $raw
}

if (-not (Test-Path -LiteralPath $PluginSource -PathType Container)) { throw "Plugin source folder is missing: $PluginSource" }
$existingPluginPath = $PluginPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1
if ($existingPluginPath) { throw "Plugin already exists at $existingPluginPath. Uninstall it first to avoid overwriting a local version." }
Assert-PackageIntegrity
$Agy = Resolve-AgyCli
$Version = Get-AgyVersion -Agy $Agy
$installedByThisRun = $false

$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$stageName = 'geac-x1-r1-stage-' + [Guid]::NewGuid().ToString('N')
$stagePath = Join-Path $tempRoot $stageName
New-Item -ItemType Directory -Path $stagePath | Out-Null
try {
    Copy-Item -Path (Join-Path $PluginSource '*') -Destination $stagePath -Recurse
    Copy-Item -LiteralPath (Join-Path $PackageRoot 'install\hooks.windows.json') -Destination (Join-Path $stagePath 'hooks.json')
    Push-Location $PackageRoot
    try {
        & $Agy plugin validate $stagePath
        if ($LASTEXITCODE -ne 0) { throw 'AGY rejected the staged plugin.' }
        & $Agy plugin install $stagePath
        if ($LASTEXITCODE -ne 0) { throw 'AGY plugin installation failed.' }
        $installedByThisRun = $true
    } finally { Pop-Location }
    & (Join-Path $PackageRoot 'Verify-GEAC-X1-R1.ps1')
    Write-Output "Installed GEAC X1-R1 package preview with AGY CLI $Version."
} catch {
    if ($installedByThisRun) {
        & $Agy plugin uninstall $PluginName | Out-Null
    }
    throw
} finally {
    $resolvedStage = [IO.Path]::GetFullPath($stagePath)
    $requiredPrefix = $tempRoot + [IO.Path]::DirectorySeparatorChar + 'geac-x1-r1-stage-'
    if ($resolvedStage.StartsWith($requiredPrefix, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedStage)) {
        Remove-Item -LiteralPath $resolvedStage -Recurse -Force
    } elseif (Test-Path -LiteralPath $resolvedStage) {
        throw "Refusing to remove staging path outside expected temp prefix: $resolvedStage"
    }
}
