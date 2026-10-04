[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PackageRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$PluginName = 'geac-x1-r1-engineering-controls'
$PluginPaths = @(
    (Join-Path $HOME ('.gemini\config\plugins\' + $PluginName)),
    (Join-Path $HOME ('.gemini\antigravity-cli\plugins\' + $PluginName))
)
$InstallPath = $PluginPaths | Where-Object { Test-Path -LiteralPath $_ -PathType Container } | Select-Object -First 1
$AgyCmd = Get-Command 'agy' -ErrorAction SilentlyContinue
$Agy = if ($AgyCmd -and $AgyCmd.Source) { $AgyCmd.Source } else { Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe' }
if (-not (Test-Path -LiteralPath $Agy -PathType Leaf)) { throw 'AGY CLI was not found.' }
if (-not $InstallPath) { throw "Installed plugin directory was not found. Checked: $($PluginPaths -join ', ')" }
$list = (& $Agy plugin list | Out-String)
if ($list -notmatch [regex]::Escape($PluginName)) { throw "AGY plugin list does not show $PluginName." }
& $Agy plugin validate $InstallPath
if ($LASTEXITCODE -ne 0) { throw 'AGY rejected the installed plugin.' }
foreach ($line in Get-Content -LiteralPath (Join-Path $PackageRoot 'PLUGIN-SHA256.txt')) {
    if ($line -notmatch '^([0-9a-fA-F]{64})  (.+)$') { throw "Malformed PLUGIN-SHA256.txt line: $line" }
    $expected=$Matches[1].ToLowerInvariant(); $rel=$Matches[2]
    $target=Join-Path $InstallPath ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Installed plugin file missing: $rel" }
    $actual=(Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { throw "Installed plugin hash mismatch: $rel" }
}
$hookExpected=(Get-FileHash -LiteralPath (Join-Path $PackageRoot 'install\hooks.windows.json') -Algorithm SHA256).Hash.ToLowerInvariant()
$hookActual=(Get-FileHash -LiteralPath (Join-Path $InstallPath 'hooks.json') -Algorithm SHA256).Hash.ToLowerInvariant()
if ($hookActual -ne $hookExpected) { throw 'Installed Windows hooks.json does not match the packaged hook template.' }
Write-Output "PASS: $PluginName is installed, AGY-valid, and matches the packaged Windows component hashes."
