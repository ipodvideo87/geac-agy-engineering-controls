$ErrorActionPreference = 'Stop'

# GEAC Forced Required-Gate Hook — FG-v1
#
# Contract:
#   canonical skill name begins "required-gate-" -> FORCE
#   every other skill                              -> DO NOT TOUCH
#
# The hook does not decide relevance or applicability.
# It mechanically supplies every required-gate-* contract to every
# model invocation through a PreInvocation ephemeral system message.

$null = [Console]::In.ReadToEnd()

$SkillRoot = Join-Path $HOME '.gemini\antigravity-cli\skills'

if (-not (Test-Path -LiteralPath $SkillRoot -PathType Container)) {
    throw "Required skill root does not exist: $SkillRoot"
}

$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Remove-YamlQuotes {
    param([string]$Value)

    if ($null -eq $Value) {
        return $null
    }

    $v = $Value.Trim()

    if (
        ($v.StartsWith('"') -and $v.EndsWith('"')) -or
        ($v.StartsWith("'") -and $v.EndsWith("'"))
    ) {
        return $v.Substring(1, $v.Length - 2)
    }

    return $v
}

function Get-CanonicalSkillName {
    param(
        [Parameter(Mandatory)]
        [string]$SkillFile,

        [Parameter(Mandatory)]
        [string]$FolderName
    )

    $lines = [System.IO.File]::ReadAllLines(
        $SkillFile,
        [System.Text.Encoding]::UTF8
    )

    if ($lines.Count -gt 2 -and $lines[0].Trim() -eq '---') {
        $end = -1

        for ($i = 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -eq '---') {
                $end = $i
                break
            }
        }

        if ($end -gt 0) {
            for ($i = 1; $i -lt $end; $i++) {
                if ($lines[$i] -match '^\s*name\s*:\s*(.+?)\s*$') {
                    $name = Remove-YamlQuotes $Matches[1]

                    if (-not [string]::IsNullOrWhiteSpace($name)) {
                        return $name
                    }
                }
            }
        }
    }

    # AGY skill identity falls back to the containing folder name
    # when no explicit canonical name is supplied.
    return $FolderName
}

$RequiredGates = @(
    foreach ($dir in @(
        Get-ChildItem -LiteralPath $SkillRoot -Directory |
        Sort-Object Name
    )) {
        $SkillFile = Join-Path $dir.FullName 'SKILL.md'

        if (-not (Test-Path -LiteralPath $SkillFile -PathType Leaf)) {
            continue
        }

        $CanonicalName = Get-CanonicalSkillName `
            -SkillFile $SkillFile `
            -FolderName $dir.Name

        # ----------------------------------------------------------
        # FG-v1 ENFORCEMENT BOUNDARY
        # ----------------------------------------------------------
        #
        # required-gate-*:
        #     forcibly included
        #
        # everything else:
        #     ignored by this hook and left to native AGY selection
        #
        # There is intentionally NO relevance/applicability test here.
        # ----------------------------------------------------------

        if ($CanonicalName -like 'required-gate-*') {
            $Hash = (
                Get-FileHash `
                    -LiteralPath $SkillFile `
                    -Algorithm SHA256
            ).Hash.ToLowerInvariant()

            [pscustomobject]@{
                CanonicalName = $CanonicalName
                SkillFile     = $SkillFile
                SHA256        = $Hash
            }
        }
    }
)

if ($RequiredGates.Count -eq 0) {
    throw 'No canonical required-gate-* skills were found.'
}

$DuplicateNames = @(
    $RequiredGates |
    Group-Object CanonicalName |
    Where-Object Count -gt 1
)

if ($DuplicateNames.Count -gt 0) {
    $Names = ($DuplicateNames.Name | Sort-Object) -join ', '
    throw "Duplicate canonical required-gate names detected: $Names"
}

$RequiredGates = @(
    $RequiredGates |
    Sort-Object CanonicalName
)

$GateList = (
    $RequiredGates |
    ForEach-Object {
        "  - $($_.CanonicalName)"
    }
) -join [Environment]::NewLine

$Header = @"
GEAC FORCED REQUIRED-GATE INTERCEPT — FG-v1

ENFORCEMENT CONTRACT

Every installed skill whose canonical skill name begins with
"required-gate-" is a mandatory semantic control for this model invocation.

The required-gate set below was selected mechanically by this PreInvocation
hook from canonical skill identity.

NO relevance test was applied.
NO applicability test was applied.
NO model choice was used to select among required gates.

Every supplied required gate MUST participate in the current reasoning and
must constrain any reasoning, evidence interpretation, inference, proposed
action, engineering-status determination, test interpretation, readiness or
completion determination, historical interpretation, recommendation, and
material output claim within the semantic domain governed by that gate.

The model may not omit, suppress, deselect, substitute, or bypass a supplied
required gate because it considers the gate irrelevant, unnecessary,
redundant, inconvenient, already satisfied, or unlikely to change the result.

Mandatory participation does NOT establish any proposition being evaluated.
The individual gate contracts continue to govern evidence, inference,
identity, verification, criteria, necessity, history, and output admission.

NON-REQUIRED SKILLS

This intercept does not force any skill whose canonical name does NOT begin
with "required-gate-".

All non-required-gate skills remain subject to normal AGY discovery,
relevance selection, activation, and progressive disclosure.

Mechanically forced required-gate count: $($RequiredGates.Count)

Mechanically forced canonical names:
$GateList

The complete required-gate contracts follow.
"@

$Sections = @(
    foreach ($Gate in $RequiredGates) {
        $Content = [System.IO.File]::ReadAllText(
            $Gate.SkillFile,
            [System.Text.Encoding]::UTF8
        )

        @"
======================================================================
REQUIRED GATE BEGIN
Canonical-Name: $($Gate.CanonicalName)
Source-Path: $($Gate.SkillFile)
Source-SHA256: $($Gate.SHA256)
======================================================================

$Content

======================================================================
REQUIRED GATE END
Canonical-Name: $($Gate.CanonicalName)
======================================================================
"@
    }
)

$Message = @(
    $Header
    ''
    ($Sections -join ([Environment]::NewLine + [Environment]::NewLine))
) -join [Environment]::NewLine

$Result = [ordered]@{
    injectSteps = @(
        [ordered]@{
            ephemeralMessage = $Message
        }
    )
}

$Json = $Result | ConvertTo-Json -Depth 12 -Compress

[Console]::OutputEncoding = $Utf8
[Console]::Out.WriteLine($Json)