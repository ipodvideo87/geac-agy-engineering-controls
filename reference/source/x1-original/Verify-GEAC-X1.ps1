[CmdletBinding()]
param(
    [string]$PackageRoot = $PSScriptRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-X1TargetPath {
    param([Parameter(Mandatory = $true)][string]$Target)
    if (-not $Target.StartsWith('.gemini/')) {
        throw "Refusing target outside .gemini: $Target"
    }
    $relative = ($Target -split '/') -join [IO.Path]::DirectorySeparatorChar
    return (Join-Path $HOME $relative)
}

$manifestPath = Join-Path $PackageRoot 'X1-PAYLOAD-MANIFEST.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Manifest not found: $manifestPath"
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

$failed = $false
foreach ($entry in $manifest.files) {
    $targetPath = Resolve-X1TargetPath -Target $entry.target
    if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
        Write-Host "MISSING       $($entry.target)"
        $failed = $true
        continue
    }
    $actual = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $expected = ([string]$entry.sha256).ToLowerInvariant()
    if ($actual -ne $expected) {
        Write-Host "HASH_MISMATCH $($entry.target)"
        Write-Host "  expected: $expected"
        Write-Host "  actual:   $actual"
        $failed = $true
    }
    else {
        Write-Host "OK            $($entry.target)"
    }
}

if ($failed) {
    Write-Error 'GEAC X1 installed-byte verification FAILED.'
    exit 1
}

Write-Host "GEAC X1 installed-byte verification PASSED: $($manifest.contract_id)"
exit 0
