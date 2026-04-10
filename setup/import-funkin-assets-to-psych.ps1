param(
    [string]$SourceRoot = (Join-Path $PSScriptRoot '..\..\funkin-windows-64bit\assets'),
    [string]$PsychRoot = (Join-Path $PSScriptRoot '..')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-NormalPath {
    param([string]$Path)
    return [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).Path)
}

function Format-SongPath {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return '' }
    $value = $Name.ToLowerInvariant()
    $value = [regex]::Replace($value, '[^a-z0-9]+', '-')
    $value = $value.Trim('-')
    if ([string]::IsNullOrWhiteSpace($value)) { return 'unknown' }
    return $value
}

function Get-PropValue {
    param(
        $Object,
        [string]$Name
    )

    if ($null -eq $Object) { return $null }
    $prop = $Object.PSObject.Properties[$Name]
    if ($null -ne $prop) { return $prop.Value }
    return $null
}

function Convert-StageName {
    param([string]$Stage)
    switch ($Stage) {
        'mainStage' { return 'stage' }
        'spookyMansion' { return 'spooky' }
        'phillyTrain' { return 'philly' }
        'limoRide' { return 'limo' }
        'mallXmas' { return 'mall' }
        'tankmanBattlefield' { return 'tank' }
        default {
            if ([string]::IsNullOrWhiteSpace($Stage)) { return 'stage' }
            return $Stage
        }
    }
}

function Get-Crochet {
    param([double]$Bpm)
    if ($Bpm -le 0) { return 500.0 }
    return (60.0 / $Bpm) * 1000.0
}

function New-EmptySection {
    return [ordered]@{
        sectionNotes = @()
        sectionBeats = 4
        mustHitSection = $false
    }
}

function Get-DifficultyFileSuffix {
    param([string]$DifficultyName)
    $formatted = Format-SongPath $DifficultyName
    if ($formatted -eq 'normal' -or [string]::IsNullOrWhiteSpace($formatted)) {
        return ''
    }
    return "-$formatted"
}

function Convert-VSliceToPsych {
    param(
        [string]$ChartPath,
        [string]$MetadataPath,
        [string]$PsychSongId,
        [string]$DisplayName
    )

    $chart = Get-Content -LiteralPath $ChartPath -Raw | ConvertFrom-Json
    $metadata = Get-Content -LiteralPath $MetadataPath -Raw | ConvertFrom-Json

    $allEvents = @($chart.events | Sort-Object { [double]$_.t })
    $timeChanges = @($metadata.timeChanges | Sort-Object { [double]$_.t })
    if ($timeChanges.Count -lt 1) {
        throw "No time changes in $MetadataPath"
    }

    $songBpm = [double]$timeChanges[0].bpm
    $remainingTimeChanges = @()
    if ($timeChanges.Count -gt 1) {
        $remainingTimeChanges = $timeChanges[1..($timeChanges.Count - 1)]
    }

    $focusCameraEvents = @($allEvents | Where-Object {
        $_.e -eq 'FocusCamera' -and (
            $null -ne (Get-PropValue $_.v 'char') -or
            $_.v -eq 0 -or $_.v -eq 1 -or $_.v -eq '0' -or $_.v -eq '1'
        )
    })

    $sectionMustHits = @()
    if ($focusCameraEvents.Count -gt 0) {
        $time = 0.0
        $focusIndex = 0
        $lastMustHit = $false

        while ($time -lt [double]$focusCameraEvents[-1].t) {
            $bpm = $songBpm
            foreach ($change in $remainingTimeChanges) {
                if ($time -lt [double]$change.t) { break }
                $bpm = [double]$change.bpm
            }

            for ($i = $focusIndex; $i -lt $focusCameraEvents.Count; $i++) {
                $focusEvent = $focusCameraEvents[$i]
                if (($time + 1.0) -lt [double]$focusEvent.t) {
                    $focusIndex = $i
                    break
                }

                $focusValue = Get-PropValue $focusEvent 'v'
                $char = Get-PropValue $focusValue 'char'
                if ($null -eq $char) { $char = $focusValue }
                if ($null -eq $char -or [string]::IsNullOrWhiteSpace("$char")) { $char = '1' }
                $lastMustHit = ("$char" -eq '0')
            }

            $sectionMustHits += $lastMustHit
            $time += (Get-Crochet $bpm) * 4.0
        }
    }

    if ($sectionMustHits.Count -lt 1) { $sectionMustHits += $false }

    $difficulties = @($metadata.playData.difficulties)
    $notesByDifficulty = @{}
    $lastNoteTime = 0.0
    foreach ($diff in $difficulties) {
        $diffNotes = @(Get-PropValue $chart.notes $diff)
        if ($null -eq $diffNotes) { $diffNotes = @() }
        $diffNotes = @($diffNotes | Sort-Object { [double]$_.t })
        $notesByDifficulty[$diff] = $diffNotes
        if ($diffNotes.Count -gt 0) {
            $candidate = [double]$diffNotes[-1].t
            if ($candidate -gt $lastNoteTime) { $lastNoteTime = $candidate }
        }
    }

    $sectionTimes = @()
    $baseSections = @()
    $bpm = $songBpm
    $lastBpm = $songBpm
    $time = 0.0
    while ($time -lt $lastNoteTime) {
        foreach ($change in $remainingTimeChanges) {
            if ($time -lt [double]$change.t) { break }
            $bpm = [double]$change.bpm
        }

        $sectionTime = (Get-Crochet $bpm) * 4.0
        $sectionTimes += $time
        $time += $sectionTime

        $section = New-EmptySection
        $index = $baseSections.Count
        $section.mustHitSection = if ($index -ge $sectionMustHits.Count) { $sectionMustHits[-1] } else { $sectionMustHits[$index] }
        if ($lastBpm -ne $bpm) {
            $section.changeBPM = $true
            $section.bpm = $bpm
            $lastBpm = $bpm
        }
        $baseSections += $section
    }

    if ($baseSections.Count -eq 0) {
        $baseSections += (New-EmptySection)
        $sectionTimes += 0.0
    }

    $characters = $metadata.playData.characters
    $playerCharacter = "$(Get-PropValue $characters 'player')"
    $opponentCharacter = "$(Get-PropValue $characters 'opponent')"
    $girlfriendCharacter = "$(Get-PropValue $characters 'girlfriend')"
    if ([string]::IsNullOrWhiteSpace($playerCharacter)) { $playerCharacter = 'bf' }
    if ([string]::IsNullOrWhiteSpace($opponentCharacter)) { $opponentCharacter = 'dad' }
    if ([string]::IsNullOrWhiteSpace($girlfriendCharacter)) { $girlfriendCharacter = 'gf' }

    $convertedSongs = @{}
    foreach ($diff in $difficulties) {
        $diffNotes = @($notesByDifficulty[$diff])
        $scrollSpeed = Get-PropValue $chart.scrollSpeed $diff
        if ($null -eq $scrollSpeed) { $scrollSpeed = Get-PropValue $chart.scrollSpeed 'default' }
        if ($null -eq $scrollSpeed) { $scrollSpeed = 1.0 }

        $sectionData = @()
        foreach ($baseSection in $baseSections) {
            $section = New-EmptySection
            $section.mustHitSection = $baseSection.mustHitSection
            if ($null -ne (Get-PropValue $baseSection 'changeBPM')) {
                $section.changeBPM = $baseSection.changeBPM
                $section.bpm = $baseSection.bpm
            }
            $sectionData += $section
        }

        $noteSection = 0
        foreach ($note in $diffNotes) {
            while (($noteSection + 1) -lt $sectionTimes.Count -and [double]$sectionTimes[$noteSection + 1] -le [double]$note.t) {
                $noteSection++
            }

            $noteLength = Get-PropValue $note 'l'
            $noteKind = Get-PropValue $note 'k'
            $psychNote = @([double]$note.t, [int]$note.d, $(if ($null -ne $noteLength) { [double]$noteLength } else { 0.0 }))
            if (-not [string]::IsNullOrWhiteSpace("$noteKind") -and "$noteKind" -ne 'normal') {
                $psychNote += "$noteKind"
            }

            $sectionData[$noteSection].sectionNotes += ,$psychNote
        }

        $prettyDiff = if ([string]::IsNullOrWhiteSpace($diff)) { 'Normal' } else { (Get-Culture).TextInfo.ToTitleCase("$diff") }
        $songDisplay = if ($prettyDiff -ieq 'Normal') { $DisplayName } else { "$DisplayName [$prettyDiff]" }

        $convertedSongs[$diff] = [ordered]@{
            song = $songDisplay
            notes = $sectionData
            events = @()
            bpm = $songBpm
            needsVoices = $true
            speed = [double]$scrollSpeed
            offset = 0
            player1 = $playerCharacter
            player2 = $opponentCharacter
            gfVersion = $girlfriendCharacter
            stage = (Convert-StageName "$($metadata.playData.stage)")
            format = 'psych_v1_convert'
            artist = "$($metadata.artist)"
            charter = "$($metadata.charter)"
            generatedBy = 'Ported from Funkin V-Slice metadata'
        }
    }

    $eventList = @()
    foreach ($event in $allEvents) {
        $eventName = "$(Get-PropValue $event 'e')"
        $eventValue = Get-PropValue $event 'v'
        if ($eventName -eq 'FocusCamera') { continue }

        $value1 = ''
        $value2 = ''
        if ($null -ne $eventValue) {
            if ($eventValue -is [System.Array]) {
                $eventArray = @($eventValue)
                if ($eventArray.Count -gt 0) { $value1 = "$($eventArray[0])" }
                if ($eventArray.Count -gt 1) { $value2 = "$($eventArray[1])" }
            }
            elseif ($eventValue -is [PSCustomObject]) {
                switch ($eventName) {
                    'PlayAnimation' {
                        $value1 = "$(Get-PropValue $eventValue 'anim')"
                        $target = Get-PropValue $eventValue 'target'
                        $force = Get-PropValue $eventValue 'force'
                        if ($null -ne $target) { $value2 = "$target" }
                        if ($null -ne $force -and "$force" -ne '') {
                            if ([string]::IsNullOrWhiteSpace($value2)) { $value2 = "force=$force" } else { $value2 = "$value2|force=$force" }
                        }
                    }
                    'SetCameraBop' {
                        $value1 = "$(Get-PropValue $eventValue 'rate')"
                        $intensity = Get-PropValue $eventValue 'intensity'
                        $offset = Get-PropValue $eventValue 'offset'
                        $parts = @()
                        if ($null -ne $intensity) { $parts += "$intensity" }
                        if ($null -ne $offset) { $parts += "$offset" }
                        $value2 = ($parts -join '|')
                    }
                    'ZoomCamera' {
                        $value1 = "$(Get-PropValue $eventValue 'zoom')"
                        $parts = @()
                        foreach ($propName in @('duration', 'ease', 'mode')) {
                            $propValue = Get-PropValue $eventValue $propName
                            if ($null -ne $propValue) { $parts += "$propValue" }
                        }
                        $value2 = ($parts -join '|')
                    }
                    'ScrollSpeed' {
                        $value1 = "$(Get-PropValue $eventValue 'scroll')"
                        $parts = @()
                        foreach ($propName in @('duration', 'ease', 'strumline', 'absolute')) {
                            $propValue = Get-PropValue $eventValue $propName
                            if ($null -ne $propValue) { $parts += "$propValue" }
                        }
                        $value2 = ($parts -join '|')
                    }
                    default {
                        $fields = @()
                        foreach ($prop in $eventValue.PSObject.Properties) {
                            $fields += "$($prop.Value)"
                        }
                        if ($fields.Count -gt 0) { $value1 = "$($fields[0])" }
                        if ($fields.Count -gt 1) { $value2 = "$($fields[1])" }
                    }
                }
            }
            else {
                $value1 = "$eventValue"
            }
        }

        $eventList += ,@([double]$event.t, @(@($eventName, $value1, $value2)))
    }

    return [ordered]@{
        Metadata = $metadata
        SongId = $PsychSongId
        Difficulties = $convertedSongs
        Events = [ordered]@{
            events = @($eventList | Sort-Object { [double]$_[0] })
            format = 'psych_v1_convert'
        }
    }
}

function Convert-SourceStageDataToPsych {
    param(
        $StageData,
        [string]$ExistingDirectory = ''
    )

    if ($null -eq $StageData) { return $null }

    $characters = Get-PropValue $StageData 'characters'
    $bf = Get-PropValue $characters 'bf'
    $dad = Get-PropValue $characters 'dad'
    $gf = Get-PropValue $characters 'gf'

    $objects = @()
    $props = @(Get-PropValue $StageData 'props')
    $sortedProps = @($props | Sort-Object {
        $z = Get-PropValue $_ 'zIndex'
        if ($null -eq $z) { return 0 }
        return [double]$z
    })

    foreach ($prop in $sortedProps) {
        $assetPath = "$(Get-PropValue $prop 'assetPath')"
        $name = "$(Get-PropValue $prop 'name')"
        $position = @(Get-PropValue $prop 'position'); if ($position.Count -lt 2) { $position = @(0,0) }
        $scale = @(Get-PropValue $prop 'scale'); if ($scale.Count -lt 2) { $scale = @(1,1) }
        $scroll = @(Get-PropValue $prop 'scroll'); if ($scroll.Count -lt 2) { $scroll = @(1,1) }
        $animationsValue = Get-PropValue $prop 'animations'
        $animations = @(); if ($null -ne $animationsValue) { $animations = @($animationsValue) }
        $startingAnimation = "$(Get-PropValue $prop 'startingAnimation')"

        $object = [ordered]@{
            name = $name
            x = [double]$position[0]
            y = [double]$position[1]
            scale = @([double]$scale[0], [double]$scale[1])
            scroll = @([double]$scroll[0], [double]$scroll[1])
        }

        $alpha = Get-PropValue $prop 'alpha'; if ($null -ne $alpha) { $object.alpha = [double]$alpha }
        $angle = Get-PropValue $prop 'angle'; if ($null -ne $angle) { $object.angle = [double]$angle }
        $flipX = Get-PropValue $prop 'flipX'; if ($null -ne $flipX) { $object.flipX = [bool]$flipX }
        $flipY = Get-PropValue $prop 'flipY'; if ($null -ne $flipY) { $object.flipY = [bool]$flipY }

        if ($assetPath.StartsWith('#')) {
            $object.type = 'square'
            $object.color = $assetPath
        }
        elseif ($animations.Count -gt 0) {
            $object.type = 'animatedSprite'
            $object.image = $assetPath
            $object.animations = @()
            foreach ($anim in $animations) {
                $object.animations += [ordered]@{
                    anim = "$(Get-PropValue $anim 'name')"
                    name = "$(Get-PropValue $anim 'prefix')"
                    fps = [int]$(if ($null -ne (Get-PropValue $anim 'frameRate')) { Get-PropValue $anim 'frameRate' } else { 24 })
                    loop = [bool]$(if ($null -ne (Get-PropValue $anim 'looped')) { Get-PropValue $anim 'looped' } else { $false })
                    indices = @()
                    offsets = @(0,0)
                }
            }
            if (-not [string]::IsNullOrWhiteSpace($startingAnimation)) { $object.firstAnimation = $startingAnimation }
        }
        else {
            $object.type = 'sprite'
            $object.image = $assetPath
        }

        $objects += $object
    }

    return [ordered]@{
        directory = $ExistingDirectory
        defaultZoom = [double]$(if ($null -ne (Get-PropValue $StageData 'cameraZoom')) { Get-PropValue $StageData 'cameraZoom' } else { 0.9 })
        stageUI = 'normal'
        boyfriend = @([double]$bf.position[0], [double]$bf.position[1])
        girlfriend = @([double]$gf.position[0], [double]$gf.position[1])
        opponent = @([double]$dad.position[0], [double]$dad.position[1])
        hide_girlfriend = $false
        camera_boyfriend = @([double]$bf.cameraOffsets[0], [double]$bf.cameraOffsets[1])
        camera_opponent = @([double]$dad.cameraOffsets[0], [double]$dad.cameraOffsets[1])
        camera_girlfriend = @([double]$gf.cameraOffsets[0], [double]$gf.cameraOffsets[1])
        camera_speed = 1
        objects = $objects
        _editorMeta = [ordered]@{
            dad = 'dad'
            boyfriend = 'bf'
            gf = 'gf'
        }
    }
}

function New-OrReplaceJunction {
    param(
        [string]$Path,
        [string]$Target
    )

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
    New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
}

$sourceRoot = Resolve-NormalPath $SourceRoot
$psychRoot = Resolve-NormalPath $PsychRoot
$baseRoot = Join-Path $psychRoot 'assets\base_game'
$sharedRoot = Join-Path $baseRoot 'shared'
$sharedDataRoot = Join-Path $sharedRoot 'data'
$sharedStagesRoot = Join-Path $sharedRoot 'stages'
$sharedCharactersRoot = Join-Path $sharedRoot 'characters'
$portMirrorRoot = Join-Path $baseRoot '_source_port'

foreach ($path in @($baseRoot, $sharedRoot, $sharedDataRoot, $sharedStagesRoot, $sharedCharactersRoot, $portMirrorRoot)) {
    New-Item -ItemType Directory -Path $path -Force | Out-Null
}

# Mirror raw top-level asset trees for later manual/source work.
$mirrorMappings = @(
    @{ Source = (Join-Path $sourceRoot 'scripts'); Destination = (Join-Path $portMirrorRoot 'scripts') },
    @{ Source = (Join-Path $sourceRoot 'shaders'); Destination = (Join-Path $portMirrorRoot 'shaders') },
    @{ Source = (Join-Path $sourceRoot 'data\dialogue'); Destination = (Join-Path $portMirrorRoot 'data\dialogue') },
    @{ Source = (Join-Path $sourceRoot 'data\levels'); Destination = (Join-Path $portMirrorRoot 'data\levels') },
    @{ Source = (Join-Path $sourceRoot 'data\players'); Destination = (Join-Path $portMirrorRoot 'data\players') },
    @{ Source = (Join-Path $sourceRoot 'data\stickerpacks'); Destination = (Join-Path $portMirrorRoot 'data\stickerpacks') },
    @{ Source = (Join-Path $sourceRoot 'data\ui'); Destination = (Join-Path $portMirrorRoot 'data\ui') }
)
foreach ($mapping in $mirrorMappings) {
    if (Test-Path -LiteralPath $mapping.Source) {
        $parent = Split-Path -Parent $mapping.Destination
        if (-not [string]::IsNullOrWhiteSpace($parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        New-OrReplaceJunction -Path $mapping.Destination -Target $mapping.Source
    }
}

# Shared raw media
$sharedMediaMappings = @(
    @{ Source = (Join-Path $sourceRoot 'images'); Destination = (Join-Path $sharedRoot 'images\_ported_root_images') },
    @{ Source = (Join-Path $sourceRoot 'music'); Destination = (Join-Path $sharedRoot 'music') },
    @{ Source = (Join-Path $sourceRoot 'sounds'); Destination = (Join-Path $sharedRoot 'sounds') },
    @{ Source = (Join-Path $sourceRoot 'shaders'); Destination = (Join-Path $sharedRoot 'shaders') },
    @{ Source = (Join-Path $sourceRoot 'shared\images'); Destination = (Join-Path $sharedRoot 'images\_ported_shared_images') },
    @{ Source = (Join-Path $sourceRoot 'shared\music'); Destination = (Join-Path $sharedRoot 'music\shared') },
    @{ Source = (Join-Path $sourceRoot 'shared\sounds'); Destination = (Join-Path $sharedRoot 'sounds\shared') }
)
foreach ($mapping in $sharedMediaMappings) {
    if (Test-Path -LiteralPath $mapping.Source) {
        $parent = Split-Path -Parent $mapping.Destination
        if (-not [string]::IsNullOrWhiteSpace($parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        New-OrReplaceJunction -Path $mapping.Destination -Target $mapping.Source
    }
}

# Week/tutorial/sserafim raw folders
foreach ($folderName in @('tutorial','week1','week2','week3','week4','week5','week6','week7','weekend1','sserafim','videos')) {
    $sourceFolder = Join-Path $sourceRoot $folderName
    $destFolder = Join-Path $baseRoot $folderName
    if (Test-Path -LiteralPath $sourceFolder) {
        New-OrReplaceJunction -Path $destFolder -Target $sourceFolder
    }
}

# Characters
$sourceCharactersRoot = Join-Path $sourceRoot 'data\characters'
if (Test-Path -LiteralPath $sourceCharactersRoot) {
    foreach ($characterFile in Get-ChildItem -LiteralPath $sourceCharactersRoot -File -Filter '*.json') {
        Copy-Item -LiteralPath $characterFile.FullName -Destination (Join-Path $sharedCharactersRoot $characterFile.Name) -Force
    }
}

# Stages
$sourceStageDataRoot = Join-Path $sourceRoot 'data\stages'
if (Test-Path -LiteralPath $sourceStageDataRoot) {
    foreach ($sourceStageDataFile in Get-ChildItem -LiteralPath $sourceStageDataRoot -File -Filter '*.json') {
        $stageName = [System.IO.Path]::GetFileNameWithoutExtension($sourceStageDataFile.Name)
        $existingStageFilePath = Join-Path $sharedStagesRoot ($stageName + '.json')
        $existingDirectory = ''
        if (Test-Path -LiteralPath $existingStageFilePath) {
            try {
                $existingStageJson = Get-Content -LiteralPath $existingStageFilePath -Raw | ConvertFrom-Json
                $existingDirectory = "$(Get-PropValue $existingStageJson 'directory')"
            } catch {
                $existingDirectory = ''
            }
        }
        $sourceStageData = Get-Content -LiteralPath $sourceStageDataFile.FullName -Raw | ConvertFrom-Json
        $convertedStage = Convert-SourceStageDataToPsych -StageData $sourceStageData -ExistingDirectory $existingDirectory
        if ($null -ne $convertedStage) {
            $convertedStage | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $existingStageFilePath -Encoding UTF8
        }
    }
}

# Stage script mirrors for manual follow-up.
$sourceStageScriptsRoot = Join-Path $sourceRoot 'scripts\stages'
$baseStageScriptMirrorRoot = Join-Path $sharedStagesRoot '_source_scripts'
New-Item -ItemType Directory -Path $baseStageScriptMirrorRoot -Force | Out-Null
if (Test-Path -LiteralPath $sourceStageScriptsRoot) {
    foreach ($scriptFile in Get-ChildItem -LiteralPath $sourceStageScriptsRoot -File) {
        Copy-Item -LiteralPath $scriptFile.FullName -Destination (Join-Path $baseStageScriptMirrorRoot $scriptFile.Name) -Force
    }
}

# Songs/charts
$sourceSongDataRoot = Join-Path $sourceRoot 'data\songs'
$sourceSongsAudioRoot = Join-Path $sourceRoot 'songs'
if (Test-Path -LiteralPath $sourceSongDataRoot) {
    $metadataFiles = @(Get-ChildItem -LiteralPath $sourceSongDataRoot -Recurse -File -Filter '*-metadata*.json' | Sort-Object FullName)
    foreach ($metadataFile in $metadataFiles) {
        $songFolder = Split-Path -Parent $metadataFile.FullName
        $songIdBase = Split-Path -Leaf $songFolder
        $metadataBaseName = [System.IO.Path]::GetFileNameWithoutExtension($metadataFile.Name)
        $chartBaseName = $metadataBaseName -replace '-metadata', '-chart'
        $chartPath = Join-Path $songFolder "$chartBaseName.json"
        if (-not (Test-Path -LiteralPath $chartPath)) { continue }

        $suffix = $metadataBaseName.Substring(($songIdBase + '-metadata').Length).TrimStart('-')
        $psychSongId = if ([string]::IsNullOrWhiteSpace($suffix)) { Format-SongPath $songIdBase } else { "$(Format-SongPath $songIdBase)-$(Format-SongPath $suffix)" }

        $metadataPreview = Get-Content -LiteralPath $metadataFile.FullName -Raw | ConvertFrom-Json
        $songDisplay = if ([string]::IsNullOrWhiteSpace($suffix)) { "$($metadataPreview.songName)" } else { "$($metadataPreview.songName) ($suffix)" }

        $converted = Convert-VSliceToPsych -ChartPath $chartPath -MetadataPath $metadataFile.FullName -PsychSongId $psychSongId -DisplayName $songDisplay
        $psychDataRoot = Join-Path $sharedDataRoot $psychSongId
        New-Item -ItemType Directory -Path $psychDataRoot -Force | Out-Null

        foreach ($diff in $converted.Difficulties.Keys) {
            $fileName = "$psychSongId$(Get-DifficultyFileSuffix $diff).json"
            $converted.Difficulties[$diff] | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $psychDataRoot $fileName) -Encoding UTF8
        }

        if ($converted.Events.events.Count -gt 0) {
            $converted.Events | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $psychDataRoot 'events.json') -Encoding UTF8
        }

        $sourceSongAudio = Join-Path $sourceSongsAudioRoot $songIdBase
        $destSongAudio = Join-Path $baseRoot "songs\$psychSongId"
        if (Test-Path -LiteralPath $sourceSongAudio) {
            New-OrReplaceJunction -Path $destSongAudio -Target $sourceSongAudio
        }
    }
}

# Root data files
foreach ($fileName in @('introText.txt','medals.json')) {
    $sourceFile = Join-Path $sourceRoot "data\$fileName"
    $destFile = Join-Path $sharedRoot $fileName
    if (Test-Path -LiteralPath $sourceFile) {
        Copy-Item -LiteralPath $sourceFile -Destination $destFile -Force
    }
}

$reportPath = Join-Path $psychRoot 'docs\FUNKIN_BASE_ASSET_PORT_REPORT.md'
$reportLines = @(
    '# Funkin Base Asset Port Report',
    '',
    '- Source: `funkin-windows-64bit/assets`',
    '- Destination: `FNF-PsychEngine/assets/base_game`',
    '- V-Slice song metadata/chart pairs were converted into `assets/base_game/shared/data/<song-id>/`.',
    '- Source stage JSONs were converted into `assets/base_game/shared/stages/*.json`.',
    '- Raw audio/media/week folders were linked into `assets/base_game` with NTFS junctions to avoid duplicating the full build.',
    '- Raw source stage scripts were mirrored to `assets/base_game/shared/stages/_source_scripts/` for manual follow-up.',
    '- Raw source data trees that do not map directly to Psych were mirrored under `assets/base_game/_source_port/`.'
)
$reportLines | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host "Imported base assets from $sourceRoot into $baseRoot"
