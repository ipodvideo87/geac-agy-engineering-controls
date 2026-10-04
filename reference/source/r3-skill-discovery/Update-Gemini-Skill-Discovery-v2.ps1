[CmdletBinding()]
param(
    [ValidateSet('Audit','Apply')]
    [string]$Mode = 'Audit'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$GeminiRoot = Join-Path $env:USERPROFILE '.gemini'
$SkillsRoot = Join-Path $GeminiRoot 'antigravity-cli\skills'
$GeminiMd   = Join-Path $GeminiRoot 'GEMINI.md'

$ExpectedGeminiSha256 = '4561400a6215fc8ebc3f003185269b00ebb0b0eacba81c97529195051276087e'

$Skills = @(
    [pscustomobject]@{
        OldName='geac-x1-engineering-evidence'
        NewName='evidence-source-and-claims'
        ExpectedSha256='b3dc748d2c5d7bdd757cd05009aa45585d313b2fac90a74d975e8e98cf097908'
        Description='STOP AND CHECK THE SOURCE: Use this skill whenever factual information enters engineering reasoning, a material claim depends on supplied, observed, reported, asserted, verified, absent, unknown, missing, or conflicting information, or a closed evidence boundary matters.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-transitions'
        NewName='claim-inference-and-strengthening'
        ExpectedSha256='83d2b6a863414a8fba4efabad9196c3d9c9a58ff27f0f43249beb2b3f985978f'
        Description='STOP AND CHECK THE INFERENCE: Use this skill whenever evidence or prior claims are combined, paraphrased, explained, generalized, strengthened, or used to infer a new proposition, especially mechanism, causality, scope, certainty, probability, provenance, identity, criterion, actor, environment, implementation, or authority.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-testing'
        NewName='test-scan-results-and-verification'
        ExpectedSha256='339806d69e0b93de7de4371b3891ec5f2b0dcd91e4cdd518a46a27a188f8f704'
        Description='STOP AND CHECK THE TEST OR SCAN CLAIM: Use this skill whenever tests, scans, validation results, pass/fail outcomes, test execution, assertions, coverage, test scope, test runners, verification, safety, readiness, correctness, or proposed test or scan evidence are involved.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-identity'
        NewName='artifact-identity-and-provenance'
        ExpectedSha256='0dd2355ee3bd513bd6bb155b48f0ba9b7be747ca3d7f1834012ea3354aea2f50'
        Description='STOP AND CHECK IDENTITY AND PROVENANCE: Use this skill whenever a claim depends on sameness, byte equality, artifact identity, generation, lineage, derivation, provenance, hashes, paths, metadata, IDs, timestamps, namespaces, or transfer history.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-criteria'
        NewName='readiness-and-completion-criteria'
        ExpectedSha256='886c2888dee332efd79c9b53693dd81dbc14b0b5230a0563b93dd89f07622b5e'
        Description='STOP AND CHECK THE CRITERION: Use this skill whenever a status or conclusion says or implies ready, safe, pass, fail, correct, complete, acceptable, compliant, validated, releasable, or satisfied, especially when it depends on a policy, threshold, definition, requirement, or acceptance rule.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-authority'
        NewName='action-authorization-and-necessity'
        ExpectedSha256='3d712609c54ad57aad4db06c9e24cd8630b369256860d169f30f302edff2c986'
        Description='STOP AND CHECK AUTHORIZATION OR NECESSITY: Use this skill whenever considering tools, searches, commands, mutations, research, additional evidence, or operational next steps, or whenever reasoning or output says an action is required, necessary, optional, blocking, authorized, permitted, recommended, executable, or should be performed.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-history'
        NewName='historical-evidence-preservation'
        ExpectedSha256='3c041b96f20a385ad60f3de5020a3ff20342ef3cd2148f0d9857e4fccffb113f'
        Description='STOP AND CHECK HISTORY: Use this skill whenever evidence or engineering state changes over time, or later success, failure, contradiction, remediation, replacement, revision, reconstruction, or new evidence could be interpreted as changing, erasing, or rewriting an earlier record or state.'
    },
    [pscustomobject]@{
        OldName='geac-x1-engineering-reporting'
        NewName='claim-output-validation'
        ExpectedSha256='cb210920d7f909f2f157a1e0e3726234b66e0c725147bf336c173cb6736005ff'
        Description='STOP AND CHECK THE OUTPUT CLAIM: Use this skill whenever writing, emitting, or reformulating a material case-specific engineering conclusion, explanation, heading, table entry, summary, recommendation, verdict, status statement, completion claim, self-review, or other output claim.'
    }
)

function Get-Sha256 {
    param([Parameter(Mandatory=$true)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Read-Utf8PreserveBom {
    param([Parameter(Mandatory=$true)][string]$Path)

    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = $false
    $offset = 0

    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $hasBom = $true
        $offset = 3
    }

    $length = $bytes.Length - $offset
    $text = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $length)

    return [pscustomobject]@{
        Text   = $text
        HasBom = $hasBom
    }
}

function Write-Utf8PreserveBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Text,
        [Parameter(Mandatory=$true)][bool]$HasBom
    )

    $encoding = New-Object System.Text.UTF8Encoding -ArgumentList $HasBom
    [System.IO.File]::WriteAllText($Path, $Text, $encoding)
}

function Get-FrontMatterInfo {
    param([Parameter(Mandatory=$true)][string]$Path)

    $read = Read-Utf8PreserveBom -Path $Path
    $text = $read.Text

    $options = [System.Text.RegularExpressions.RegexOptions]::Singleline
    $fmMatch = [regex]::Match($text, '\A---\r?\n(?<fm>.*?)\r?\n---(?=\r?\n|\z)', $options)
    if (-not $fmMatch.Success) {
        throw "Frontmatter block not found at start of $Path"
    }

    $fm = $fmMatch.Groups['fm'].Value
    $nameMatch = [regex]::Match($fm, '(?m)^(?<line>name:\s*(?<value>.+?)\s*)$')
    $descMatch = [regex]::Match($fm, '(?m)^(?<line>description:\s*(?<value>.*?)\s*)$')

    if (-not $nameMatch.Success) {
        throw "Single-line name: field not found in $Path"
    }
    if (-not $descMatch.Success) {
        throw "Single-line description: field not found in $Path"
    }

    $nameValue = $nameMatch.Groups['value'].Value.Trim()
    $nameValue = $nameValue.Trim('"').Trim("'")
    $descValue = $descMatch.Groups['value'].Value.Trim()

    if ($descValue -eq '|' -or $descValue -eq '>') {
        throw "Multiline YAML description detected in $Path. This script intentionally refuses to rewrite it."
    }

    return [pscustomobject]@{
        Text            = $text
        HasBom          = $read.HasBom
        FrontMatter     = $fm
        FrontMatterMatch = $fmMatch
        Name            = $nameValue
        NameLine        = $nameMatch.Groups['line'].Value
        Description     = $descValue
        DescriptionLine = $descMatch.Groups['line'].Value
    }
}

function Replace-FrontMatter {
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [Parameter(Mandatory=$true)][string]$NewName,
        [Parameter(Mandatory=$true)][string]$NewDescription
    )

    $options = [System.Text.RegularExpressions.RegexOptions]::Singleline
    $fmMatch = [regex]::Match($Text, '\A---\r?\n(?<fm>.*?)\r?\n---(?=\r?\n|\z)', $options)
    if (-not $fmMatch.Success) {
        throw 'Frontmatter block not found during replacement.'
    }

    $fm = $fmMatch.Groups['fm'].Value
    $nameRegex = New-Object System.Text.RegularExpressions.Regex -ArgumentList '(?m)^name:\s*.*$'
    $descRegex = New-Object System.Text.RegularExpressions.Regex -ArgumentList '(?m)^description:\s*.*$'

    if ($nameRegex.Matches($fm).Count -ne 1) {
        throw 'Expected exactly one name: line in frontmatter.'
    }
    if ($descRegex.Matches($fm).Count -ne 1) {
        throw 'Expected exactly one description: line in frontmatter.'
    }

    $newFm = $nameRegex.Replace($fm, ('name: ' + $NewName), 1)
    $newFm = $descRegex.Replace($newFm, ('description: ' + $NewDescription), 1)

    $start = $fmMatch.Groups['fm'].Index
    $len = $fmMatch.Groups['fm'].Length
    return $Text.Substring(0, $start) + $newFm + $Text.Substring($start + $len)
}

function Replace-AllSkillIds {
    param([Parameter(Mandatory=$true)][string]$Text)

    $result = $Text
    foreach ($skill in $Skills) {
        $result = $result.Replace($skill.OldName, $skill.NewName)
    }
    return $result
}

function Reverse-AllSkillIds {
    param([Parameter(Mandatory=$true)][string]$Text)

    $result = $Text
    foreach ($skill in $Skills) {
        $result = $result.Replace($skill.NewName, $skill.OldName)
    }
    return $result
}

function Get-RelativePathFromRoot {
    param(
        [Parameter(Mandatory=$true)][string]$Root,
        [Parameter(Mandatory=$true)][string]$Path
    )

    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $pathFull = [System.IO.Path]::GetFullPath($Path)

    if (-not $pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path is not under root: $Path"
    }

    return $pathFull.Substring($rootFull.Length).TrimStart('\')
}

function New-BackupManifest {
    param([Parameter(Mandatory=$true)][string]$StageRoot)

    $entries = @()
    $files = Get-ChildItem -LiteralPath $StageRoot -File -Recurse |
        Where-Object { $_.Name -ne 'backup-manifest.json' } |
        Sort-Object FullName

    foreach ($file in $files) {
        $entries += [pscustomobject]@{
            RelativePath = Get-RelativePathFromRoot -Root $StageRoot -Path $file.FullName
            Length       = [int64]$file.Length
            Sha256       = Get-Sha256 -Path $file.FullName
        }
    }

    return $entries
}

function Test-BackupAgainstManifest {
    param(
        [Parameter(Mandatory=$true)][string]$ExtractedRoot,
        [Parameter(Mandatory=$true)]$ManifestEntries
    )

    $actualFiles = Get-ChildItem -LiteralPath $ExtractedRoot -File -Recurse |
        Where-Object { $_.Name -ne 'backup-manifest.json' }

    if ($actualFiles.Count -ne $ManifestEntries.Count) {
        throw "Backup verification file-count mismatch. Expected $($ManifestEntries.Count), got $($actualFiles.Count)."
    }

    foreach ($entry in $ManifestEntries) {
        $path = Join-Path $ExtractedRoot $entry.RelativePath
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Backup verification missing file: $($entry.RelativePath)"
        }

        $item = Get-Item -LiteralPath $path
        if ([int64]$item.Length -ne [int64]$entry.Length) {
            throw "Backup verification size mismatch: $($entry.RelativePath)"
        }

        $sha = Get-Sha256 -Path $path
        if ($sha -ne $entry.Sha256) {
            throw "Backup verification SHA-256 mismatch: $($entry.RelativePath)"
        }
    }
}

function Assert-PreApplyState {
    $problems = @()

    if (-not (Test-Path -LiteralPath $GeminiRoot -PathType Container)) {
        $problems += "Missing Gemini root: $GeminiRoot"
    }
    if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
        $problems += "Missing skills root: $SkillsRoot"
    }
    if (-not (Test-Path -LiteralPath $GeminiMd -PathType Leaf)) {
        $problems += "Missing GEMINI.md: $GeminiMd"
    }

    if ($problems.Count -eq 0) {
        $geminiSha = Get-Sha256 -Path $GeminiMd
        if ($geminiSha -ne $ExpectedGeminiSha256) {
            $problems += "GEMINI.md SHA-256 mismatch. Expected $ExpectedGeminiSha256, got $geminiSha"
        }
    }

    foreach ($skill in $Skills) {
        $oldDir = Join-Path $SkillsRoot $skill.OldName
        $newDir = Join-Path $SkillsRoot $skill.NewName
        $skillMd = Join-Path $oldDir 'SKILL.md'

        if (-not (Test-Path -LiteralPath $oldDir -PathType Container)) {
            $problems += "Missing old skill directory: $oldDir"
            continue
        }

        if (Test-Path -LiteralPath $newDir) {
            $problems += "Proposed new skill path already exists: $newDir"
        }

        if (-not (Test-Path -LiteralPath $skillMd -PathType Leaf)) {
            $problems += "Missing SKILL.md: $skillMd"
            continue
        }

        $sha = Get-Sha256 -Path $skillMd
        if ($sha -ne $skill.ExpectedSha256) {
            $problems += "SHA-256 mismatch for $($skill.OldName). Expected $($skill.ExpectedSha256), got $sha"
            continue
        }

        try {
            $fm = Get-FrontMatterInfo -Path $skillMd
            if ($fm.Name -ne $skill.OldName) {
                $problems += "Frontmatter name mismatch in $skillMd. Expected '$($skill.OldName)', got '$($fm.Name)'"
            }
        }
        catch {
            $problems += $_.Exception.Message
        }
    }

    if ($problems.Count -gt 0) {
        Write-Host ''
        Write-Host 'PRE-APPLY STATE: FAIL' -ForegroundColor Red
        foreach ($problem in $problems) {
            Write-Host ('  - ' + $problem) -ForegroundColor Red
        }
        throw 'Pre-apply validation failed. Nothing was changed.'
    }

    Write-Host 'PRE-APPLY STATE: VERIFIED_X1_R1' -ForegroundColor Green
}

function Show-Audit {
    Assert-PreApplyState

    Write-Host ''
    Write-Host 'DISCOVERY-IDENTITY AUDIT (NO CHANGES)' -ForegroundColor Cyan
    Write-Host ('Gemini root : ' + $GeminiRoot)
    Write-Host ('Skills root : ' + $SkillsRoot)
    Write-Host ('GEMINI.md   : ' + $GeminiMd)
    Write-Host ''

    foreach ($skill in $Skills) {
        $skillMd = Join-Path (Join-Path $SkillsRoot $skill.OldName) 'SKILL.md'
        $fm = Get-FrontMatterInfo -Path $skillMd

        Write-Host ('OLD NAME      : ' + $skill.OldName) -ForegroundColor Yellow
        Write-Host ('NEW NAME      : ' + $skill.NewName) -ForegroundColor Green
        Write-Host ('CURRENT DESC  : ' + $fm.Description)
        Write-Host ('PROPOSED DESC : ' + $skill.Description)
        Write-Host ('SHA-256       : ' + (Get-Sha256 -Path $skillMd))
        Write-Host ''
    }

    $geminiText = (Read-Utf8PreserveBom -Path $GeminiMd).Text
    Write-Host 'LIVE GEMINI.md REFERENCE COUNTS:' -ForegroundColor Cyan
    foreach ($skill in $Skills) {
        $count = ([regex]::Matches($geminiText, [regex]::Escape($skill.OldName))).Count
        Write-Host ('  {0} = {1}' -f $skill.OldName, $count)
    }

    Write-Host ''
    Write-Host 'AUDIT COMPLETE: NO FILES CHANGED' -ForegroundColor Green
}

function Restore-FromStage {
    param([Parameter(Mandatory=$true)][string]$StageRoot)

    foreach ($skill in $Skills) {
        $oldDir = Join-Path $SkillsRoot $skill.OldName
        $newDir = Join-Path $SkillsRoot $skill.NewName

        if (Test-Path -LiteralPath $newDir) {
            Remove-Item -LiteralPath $newDir -Recurse -Force
        }
        if (Test-Path -LiteralPath $oldDir) {
            Remove-Item -LiteralPath $oldDir -Recurse -Force
        }
    }

    Copy-Item -LiteralPath (Join-Path $StageRoot 'GEMINI.md') -Destination $GeminiMd -Force

    foreach ($skill in $Skills) {
        $src = Join-Path $StageRoot ('antigravity-cli\skills\' + $skill.OldName)
        $dst = Join-Path $SkillsRoot $skill.OldName
        Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
    }

    Assert-PreApplyState
}

function Assert-OnlyIntendedChanges {
    param(
        [Parameter(Mandatory=$true)][string]$StageRoot,
        [Parameter(Mandatory=$true)]$OriginalFrontMatter
    )

    # GEMINI.md: only exact skill identifier substitutions are allowed.
    $oldGemini = (Read-Utf8PreserveBom -Path (Join-Path $StageRoot 'GEMINI.md')).Text
    $newGemini = (Read-Utf8PreserveBom -Path $GeminiMd).Text
    $reversedGemini = Reverse-AllSkillIds -Text $newGemini

    if ($reversedGemini -cne $oldGemini) {
        throw 'GEMINI.md changed beyond exact skill-identifier substitutions.'
    }

    foreach ($skill in $Skills) {
        $oldSkillMd = Join-Path $StageRoot ('antigravity-cli\skills\' + $skill.OldName + '\SKILL.md')
        $newSkillMd = Join-Path (Join-Path $SkillsRoot $skill.NewName) 'SKILL.md'

        $oldRead = Read-Utf8PreserveBom -Path $oldSkillMd
        $newRead = Read-Utf8PreserveBom -Path $newSkillMd
        $reversed = Reverse-AllSkillIds -Text $newRead.Text

        # Restore the original frontmatter name/description lines for byte-intent comparison.
        $fmMatch = [regex]::Match(
            $reversed,
            '\A---\r?\n(?<fm>.*?)\r?\n---(?=\r?\n|\z)',
            [System.Text.RegularExpressions.RegexOptions]::Singleline
        )
        if (-not $fmMatch.Success) {
            throw "Cannot verify frontmatter after apply for $($skill.NewName)"
        }

        $fm = $fmMatch.Groups['fm'].Value
        $nameRegex = New-Object System.Text.RegularExpressions.Regex -ArgumentList '(?m)^name:\s*.*$'
        $descRegex = New-Object System.Text.RegularExpressions.Regex -ArgumentList '(?m)^description:\s*.*$'
        $fm = $nameRegex.Replace($fm, $OriginalFrontMatter[$skill.OldName].NameLine, 1)
        $fm = $descRegex.Replace($fm, $OriginalFrontMatter[$skill.OldName].DescriptionLine, 1)

        $start = $fmMatch.Groups['fm'].Index
        $len = $fmMatch.Groups['fm'].Length
        $normalized = $reversed.Substring(0, $start) + $fm + $reversed.Substring($start + $len)

        if ($normalized -cne $oldRead.Text) {
            throw "SKILL.md for $($skill.NewName) changed beyond allowed identifier/description edits."
        }

        # Any non-SKILL.md file in the skill directory must remain byte-identical.
        $oldDir = Split-Path -Parent $oldSkillMd
        $newDir = Split-Path -Parent $newSkillMd
        $otherFiles = Get-ChildItem -LiteralPath $oldDir -File -Recurse |
            Where-Object { $_.FullName -ne $oldSkillMd }

        foreach ($oldFile in $otherFiles) {
            $rel = Get-RelativePathFromRoot -Root $oldDir -Path $oldFile.FullName
            $newFile = Join-Path $newDir $rel
            if (-not (Test-Path -LiteralPath $newFile -PathType Leaf)) {
                throw "Non-SKILL.md file missing after rename: $($skill.NewName)\$rel"
            }
            if ((Get-Sha256 -Path $oldFile.FullName) -ne (Get-Sha256 -Path $newFile)) {
                throw "Non-SKILL.md file changed unexpectedly: $($skill.NewName)\$rel"
            }
        }
    }
}

function Apply-DiscoveryRevision {
    Assert-PreApplyState

    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $tempRoot = Join-Path $env:TEMP ('GEAC-X1-R3-DISCOVERY-' + $stamp)
    $stageRoot = Join-Path $tempRoot 'staging'
    $verifyRoot = Join-Path $tempRoot 'verify'

    $zipPath = Join-Path $GeminiRoot ('GEAC-X1-PRE-R3-DISCOVERY-' + $stamp + '.zip')
    $manifestPath = Join-Path $GeminiRoot ('GEAC-X1-PRE-R3-DISCOVERY-' + $stamp + '-manifest.json')
    $receiptPath = Join-Path $GeminiRoot ('GEAC-X1-R3-DISCOVERY-' + $stamp + '-receipt.json')

    $originalFrontMatter = @{}
    $receipt = [ordered]@{
        Revision = 'X1-R3-DISCOVERY'
        Timestamp = $stamp
        Mode = 'Apply'
        Status = 'STARTED'
        GeminiRoot = $GeminiRoot
        BackupZip = $zipPath
        Manifest = $manifestPath
        SemanticLogicChanged = $false
        ChangedSurface = @(
            'Skill directory names',
            'SKILL.md frontmatter name',
            'SKILL.md frontmatter description',
            'Exact live skill identifier references in GEMINI.md and managed SKILL.md files'
        )
        Skills = @()
    }

    try {
        New-Item -ItemType Directory -Path $stageRoot -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $stageRoot 'antigravity-cli\skills') -Force | Out-Null

        Copy-Item -LiteralPath $GeminiMd -Destination (Join-Path $stageRoot 'GEMINI.md') -Force

        foreach ($skill in $Skills) {
            $oldDir = Join-Path $SkillsRoot $skill.OldName
            $skillMd = Join-Path $oldDir 'SKILL.md'
            $fm = Get-FrontMatterInfo -Path $skillMd
            $originalFrontMatter[$skill.OldName] = $fm

            $stageSkillDir = Join-Path $stageRoot ('antigravity-cli\skills\' + $skill.OldName)
            Copy-Item -LiteralPath $oldDir -Destination $stageSkillDir -Recurse -Force
        }

        $manifestEntries = New-BackupManifest -StageRoot $stageRoot
        $manifestObject = [ordered]@{
            Revision = 'X1-R3-DISCOVERY'
            BackupPurpose = 'Pre-change rollback archive for discovery-facing skill rename/description experiment'
            Timestamp = $stamp
            SourceRoot = $GeminiRoot
            Files = $manifestEntries
        }

        $manifestJson = $manifestObject | ConvertTo-Json -Depth 8
        [System.IO.File]::WriteAllText(
            (Join-Path $stageRoot 'backup-manifest.json'),
            $manifestJson,
            (New-Object System.Text.UTF8Encoding -ArgumentList $false)
        )
        [System.IO.File]::WriteAllText(
            $manifestPath,
            $manifestJson,
            (New-Object System.Text.UTF8Encoding -ArgumentList $false)
        )

        Compress-Archive -Path (Join-Path $stageRoot '*') -DestinationPath $zipPath -CompressionLevel Optimal -Force

        New-Item -ItemType Directory -Path $verifyRoot -Force | Out-Null
        Expand-Archive -LiteralPath $zipPath -DestinationPath $verifyRoot -Force

        $manifestFromZip = Get-Content -LiteralPath (Join-Path $verifyRoot 'backup-manifest.json') -Raw | ConvertFrom-Json
        Test-BackupAgainstManifest -ExtractedRoot $verifyRoot -ManifestEntries $manifestFromZip.Files

        Write-Host ('BACKUP_ZIP_VERIFIED=' + $zipPath) -ForegroundColor Green

        # Rename directories first. Move-Item removes the old live path; no loose .bak copies are left.
        foreach ($skill in $Skills) {
            $oldDir = Join-Path $SkillsRoot $skill.OldName
            $newDir = Join-Path $SkillsRoot $skill.NewName
            Move-Item -LiteralPath $oldDir -Destination $newDir
        }

        # Update each SKILL.md: discovery frontmatter + exact renamed identifiers only.
        foreach ($skill in $Skills) {
            $newSkillMd = Join-Path (Join-Path $SkillsRoot $skill.NewName) 'SKILL.md'
            $read = Read-Utf8PreserveBom -Path $newSkillMd
            $text = Replace-FrontMatter -Text $read.Text -NewName $skill.NewName -NewDescription $skill.Description
            $text = Replace-AllSkillIds -Text $text
            Write-Utf8PreserveBom -Path $newSkillMd -Text $text -HasBom $read.HasBom
        }

        # Update live GEMINI.md exact identifier references only.
        $geminiRead = Read-Utf8PreserveBom -Path $GeminiMd
        $geminiNew = Replace-AllSkillIds -Text $geminiRead.Text
        Write-Utf8PreserveBom -Path $GeminiMd -Text $geminiNew -HasBom $geminiRead.HasBom

        # Structural verification.
        foreach ($skill in $Skills) {
            $oldDir = Join-Path $SkillsRoot $skill.OldName
            $newDir = Join-Path $SkillsRoot $skill.NewName
            $newSkillMd = Join-Path $newDir 'SKILL.md'

            if (Test-Path -LiteralPath $oldDir) {
                throw "Old live skill directory still exists: $oldDir"
            }
            if (-not (Test-Path -LiteralPath $newDir -PathType Container)) {
                throw "New live skill directory missing: $newDir"
            }
            if (-not (Test-Path -LiteralPath $newSkillMd -PathType Leaf)) {
                throw "New SKILL.md missing: $newSkillMd"
            }

            $fm = Get-FrontMatterInfo -Path $newSkillMd
            if ($fm.Name -ne $skill.NewName) {
                throw "New frontmatter name mismatch for $($skill.NewName)"
            }
            if ($fm.Description -ne $skill.Description) {
                throw "New description mismatch for $($skill.NewName)"
            }
        }

        # No stale old identifiers may remain in the managed live text surfaces.
        $managedTextPaths = @($GeminiMd)
        foreach ($skill in $Skills) {
            $managedTextPaths += Join-Path (Join-Path $SkillsRoot $skill.NewName) 'SKILL.md'
        }

        foreach ($path in $managedTextPaths) {
            $text = (Read-Utf8PreserveBom -Path $path).Text
            foreach ($skill in $Skills) {
                if ($text.Contains($skill.OldName)) {
                    throw "Stale old skill identifier '$($skill.OldName)' remains in $path"
                }
            }
        }

        # Prove semantic bodies and unrelated files were not changed.
        Assert-OnlyIntendedChanges -StageRoot $stageRoot -OriginalFrontMatter $originalFrontMatter

        foreach ($skill in $Skills) {
            $newSkillMd = Join-Path (Join-Path $SkillsRoot $skill.NewName) 'SKILL.md'
            $receipt.Skills += [ordered]@{
                OldName = $skill.OldName
                NewName = $skill.NewName
                OldSha256 = $skill.ExpectedSha256
                NewSha256 = Get-Sha256 -Path $newSkillMd
                Description = $skill.Description
            }
        }

        $receipt.Status = 'APPLIED_AND_VERIFIED'
        $receipt.BackupZipSha256 = Get-Sha256 -Path $zipPath
        $receipt.GeminiMdOldSha256 = $ExpectedGeminiSha256
        $receipt.GeminiMdNewSha256 = Get-Sha256 -Path $GeminiMd
        $receipt.OldLiveSkillDirectoriesRemaining = @(
            foreach ($skill in $Skills) {
                if (Test-Path -LiteralPath (Join-Path $SkillsRoot $skill.OldName)) { $skill.OldName }
            }
        )
        $receipt.NewLiveSkillDirectoryCount = @(
            foreach ($skill in $Skills) {
                if (Test-Path -LiteralPath (Join-Path $SkillsRoot $skill.NewName) -PathType Container) { $skill.NewName }
            }
        ).Count

        $receiptJson = $receipt | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText(
            $receiptPath,
            $receiptJson,
            (New-Object System.Text.UTF8Encoding -ArgumentList $false)
        )

        Write-Host ''
        Write-Host 'STATUS=APPLIED_AND_VERIFIED' -ForegroundColor Green
        Write-Host ('BACKUP_ZIP=' + $zipPath)
        Write-Host ('BACKUP_ZIP_SHA256=' + $receipt.BackupZipSha256)
        Write-Host ('MANIFEST=' + $manifestPath)
        Write-Host ('RECEIPT=' + $receiptPath)
        Write-Host ('OLD_LIVE_SKILL_DIRECTORIES=0')
        Write-Host ('NEW_LIVE_SKILL_DIRECTORIES=' + $receipt.NewLiveSkillDirectoryCount)
        Write-Host 'SEMANTIC_LOGIC_CHANGED=NO'
    }
    catch {
        $originalError = $_.Exception.Message
        Write-Host ''
        Write-Host ('APPLY_FAILED=' + $originalError) -ForegroundColor Red
        Write-Host 'ROLLBACK=STARTING' -ForegroundColor Yellow

        $rollbackStatus = 'NOT_ATTEMPTED'
        try {
            if (Test-Path -LiteralPath $stageRoot -PathType Container) {
                Restore-FromStage -StageRoot $stageRoot
                $rollbackStatus = 'VERIFIED_ORIGINAL_STATE_RESTORED'
                Write-Host ('ROLLBACK=' + $rollbackStatus) -ForegroundColor Green
            }
            else {
                $rollbackStatus = 'FAILED_STAGE_MISSING'
                Write-Host ('ROLLBACK=' + $rollbackStatus) -ForegroundColor Red
            }
        }
        catch {
            $rollbackStatus = 'FAILED: ' + $_.Exception.Message
            Write-Host ('ROLLBACK=' + $rollbackStatus) -ForegroundColor Red
        }

        $receipt.Status = 'FAILED'
        $receipt.Error = $originalError
        $receipt.Rollback = $rollbackStatus

        try {
            $receiptJson = $receipt | ConvertTo-Json -Depth 10
            [System.IO.File]::WriteAllText(
                $receiptPath,
                $receiptJson,
                (New-Object System.Text.UTF8Encoding -ArgumentList $false)
            )
        }
        catch {}

        throw "X1-R3 discovery apply failed. $originalError Rollback: $rollbackStatus"
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($Mode -eq 'Audit') {
    Show-Audit
}
elseif ($Mode -eq 'Apply') {
    Apply-DiscoveryRevision
}
