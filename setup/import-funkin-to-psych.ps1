param(
    [string]$SourceRoot = (Join-Path $PSScriptRoot '..\..\funkin-windows-64bit'),
    [string]$DestinationRoot = (Join-Path $PSScriptRoot '..\example_mods')
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

function Get-InstCandidate {
    param(
        [string]$SongFolder,
        [string]$VariantSuffix
    )

    $files = @(Get-ChildItem -LiteralPath $SongFolder -File -Filter 'Inst*.ogg' -ErrorAction SilentlyContinue | Sort-Object Name)
    if ($files.Count -eq 0) { return $null }

    if (-not [string]::IsNullOrWhiteSpace($VariantSuffix)) {
        $exact = $files | Where-Object { $_.BaseName -ieq "Inst-$VariantSuffix" } | Select-Object -First 1
        if ($null -ne $exact) { return $exact }
    }

    $plain = $files | Where-Object { $_.BaseName -ieq 'Inst' } | Select-Object -First 1
    if ($null -ne $plain) { return $plain }

    return $files[0]
}

function Get-VoiceMatches {
    param(
        [string]$SongFolder,
        [string]$VariantSuffix,
        [string]$PlayerCharacter,
        [string]$OpponentCharacter
    )

    $voiceFiles = @(Get-ChildItem -LiteralPath $SongFolder -File -Filter 'Voices*.ogg' -ErrorAction SilentlyContinue | Sort-Object Name)
    if ($voiceFiles.Count -eq 0) {
        return [ordered]@{
            Combined = $null
            Player = $null
            Opponent = $null
        }
    }

    if ($voiceFiles.Count -eq 1) {
        return [ordered]@{
            Combined = $voiceFiles[0]
            Player = $null
            Opponent = $null
        }
    }

    $playerTokens = @(Format-SongPath $PlayerCharacter).Split('-', [System.StringSplitOptions]::RemoveEmptyEntries)
    $opponentTokens = @(Format-SongPath $OpponentCharacter).Split('-', [System.StringSplitOptions]::RemoveEmptyEntries)

    if (-not [string]::IsNullOrWhiteSpace($VariantSuffix)) {
        $variantMatch = @($voiceFiles | Where-Object { $_.BaseName.ToLowerInvariant().Contains($VariantSuffix.ToLowerInvariant()) })
        if ($variantMatch.Count -eq 1) {
            return [ordered]@{
                Combined = $variantMatch[0]
                Player = $null
                Opponent = $null
            }
        }
    }

    function Get-ScoredMatch {
        param($Candidates, [string[]]$Tokens, [System.IO.FileInfo[]]$Exclude)

        $best = $null
        $bestScore = -1
        foreach ($candidate in $Candidates) {
            if ($Exclude -contains $candidate) { continue }
            $score = 0
            foreach ($token in $Tokens) {
                if ([string]::IsNullOrWhiteSpace($token)) { continue }
                if ($candidate.BaseName.ToLowerInvariant().Contains($token.ToLowerInvariant())) {
                    $score++
                }
            }
            if ($score -gt $bestScore) {
                $best = $candidate
                $bestScore = $score
            }
        }

        if ($bestScore -le 0) { return $null }
        return $best
    }

    $player = Get-ScoredMatch -Candidates $voiceFiles -Tokens $playerTokens -Exclude @()
    $opponent = Get-ScoredMatch -Candidates $voiceFiles -Tokens $opponentTokens -Exclude @($player)

    if ($null -eq $player -and $null -eq $opponent) {
        return [ordered]@{
            Combined = $voiceFiles[0]
            Player = $null
            Opponent = $null
        }
    }

    if ($null -eq $player) {
        $player = ($voiceFiles | Where-Object { $_ -ne $opponent } | Select-Object -First 1)
    }
    if ($null -eq $opponent) {
        $opponent = ($voiceFiles | Where-Object { $_ -ne $player } | Select-Object -First 1)
    }

    return [ordered]@{
        Combined = $null
        Player = $player
        Opponent = $opponent
    }
}

function Ensure-PlaceholderCharacter {
    param(
        [string]$RepoRoot,
        [string]$ModRoot,
        [string]$CharacterName,
        [string]$Role
    )

    if ([string]::IsNullOrWhiteSpace($CharacterName)) { return }

    $modCharacters = Join-Path $ModRoot 'characters'
    New-Item -ItemType Directory -Path $modCharacters -Force | Out-Null
    $target = Join-Path $modCharacters "$CharacterName.json"
    if (Test-Path -LiteralPath $target) { return }

    $template = switch ($Role) {
        'player' { Join-Path $RepoRoot 'assets\shared\characters\bf.json' }
        'girlfriend' { Join-Path $RepoRoot 'assets\shared\characters\gf.json' }
        default { Join-Path $RepoRoot 'assets\base_game\shared\characters\dad.json' }
    }

    if (-not (Test-Path -LiteralPath $template)) { return }
    Copy-Item -LiteralPath $template -Destination $target -Force
}

function Ensure-PlaceholderStage {
    param(
        [string]$ModRoot,
        [string]$StageName
    )

    if ([string]::IsNullOrWhiteSpace($StageName)) { return }

    $stagesRoot = Join-Path $ModRoot 'stages'
    New-Item -ItemType Directory -Path $stagesRoot -Force | Out-Null
    $target = Join-Path $stagesRoot "$StageName.json"
    if (Test-Path -LiteralPath $target) { return }

    $dummy = [ordered]@{
        directory = ''
        defaultZoom = 0.9
        stageUI = 'normal'
        boyfriend = @(770, 100)
        girlfriend = @(400, 130)
        opponent = @(100, 100)
        hide_girlfriend = $false
        camera_boyfriend = @(0, 0)
        camera_opponent = @(0, 0)
        camera_girlfriend = @(0, 0)
        camera_speed = 1
        _editorMeta = [ordered]@{
            gf = 'gf'
            dad = 'dad'
            boyfriend = 'bf'
        }
    }

    $dummy | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $target -Encoding UTF8
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
            $_.v -eq 0 -or
            $_.v -eq 1 -or
            $_.v -eq '0' -or
            $_.v -eq '1'
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
        if ($null -eq $scrollSpeed) {
            $scrollSpeed = Get-PropValue $chart.scrollSpeed 'default'
        }
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
                            if ([string]::IsNullOrWhiteSpace($value2)) {
                                $value2 = "force=$force"
                            }
                            else {
                                $value2 = "$value2|force=$force"
                            }
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
                    'SetHealthIcon' {
                        $value1 = "$(Get-PropValue $eventValue 'icon')"
                        $side = Get-PropValue $eventValue 'target'
                        if ($null -eq $side) { $side = Get-PropValue $eventValue 'side' }
                        if ($null -ne $side) { $value2 = "$side" }
                    }
                    'changeStage' {
                        $preferred = Get-PropValue $eventValue 'char'
                        if ($null -eq $preferred) { $preferred = Get-PropValue $eventValue 'stage' }
                        if ($null -eq $preferred) { $preferred = Get-PropValue $eventValue 'name' }
                        if ($null -ne $preferred) { $value1 = "$preferred" }
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

    $eventList = @($eventList | Sort-Object { [double]$_[0] })

    return [ordered]@{
        Metadata = $metadata
        SongId = $PsychSongId
        Difficulties = $convertedSongs
        Events = [ordered]@{
            events = $eventList
            format = 'psych_v1_convert'
        }
    }
}

function Write-WeekFile {
    param(
        [string]$WeeksRoot,
        [string]$WeekName,
        [string]$SongDisplay,
        [string]$SongId,
        [string]$Opponent,
        [string]$Player,
        [string]$Girlfriend,
        [string[]]$Difficulties,
        [string]$ModTitle
    )

    $week = [ordered]@{
        songs = @(, @($SongId, $(if ([string]::IsNullOrWhiteSpace($Opponent)) { 'face' } else { $Opponent }), @(146, 113, 253)))
        weekCharacters = @(
            $(if ([string]::IsNullOrWhiteSpace($Opponent)) { 'dad' } else { $Opponent }),
            $(if ([string]::IsNullOrWhiteSpace($Player)) { 'bf' } else { $Player }),
            $(if ([string]::IsNullOrWhiteSpace($Girlfriend)) { 'gf' } else { $Girlfriend })
        )
        weekBackground = 'stage'
        weekBefore = ''
        storyName = $SongDisplay
        weekName = $ModTitle
        startUnlocked = $true
        hiddenUntilUnlocked = $false
        hideStoryMode = $false
        hideFreeplay = $false
        difficulties = (($Difficulties | ForEach-Object {
            if ([string]::IsNullOrWhiteSpace($_)) { 'Normal' } else { (Get-Culture).TextInfo.ToTitleCase("$_") }
        }) -join ',')
    }

    $weekPath = Join-Path $WeeksRoot "$WeekName.json"
    $week | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $weekPath -Encoding UTF8
}

function Write-CompatStub {
    param(
        [string]$Path,
        [string]$Kind,
        [string]$Name,
        [string]$SourceScript,
        [string]$TriggerName = ''
    )

    $sourceScript = $SourceScript.Replace('\', '/')
    $label = "$Kind `"$Name`""
    $body = @(
        '// Auto-generated by import-funkin-to-psych.ps1',
        'var sourcePortStubWarned = false;',
        'function sourcePortStubWarn() {',
        '    if (sourcePortStubWarned) return;',
        '    sourcePortStubWarned = true;',
        "    debugPrint('[Source Port] Placeholder active for $label. Original script: $sourceScript', FlxColor.YELLOW);",
        '}'
    )

    switch ($Kind) {
        'event' {
            $body += @(
                'function onEvent(name, value1, value2, strumTime) {',
                "    if (name == '$TriggerName') sourcePortStubWarn();",
                '}'
            )
        }
        default {
            $body += @(
                'function onCreatePost() {',
                '    sourcePortStubWarn();',
                '}'
            )
        }
    }

    [System.IO.File]::WriteAllLines($Path, $body)
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
        $position = @(Get-PropValue $prop 'position')
        $scale = @(Get-PropValue $prop 'scale')
        $scroll = @(Get-PropValue $prop 'scroll')
        $animationsValue = Get-PropValue $prop 'animations'
        $animations = @()
        if ($null -ne $animationsValue) {
            $animations = @($animationsValue)
        }
        $startingAnimation = "$(Get-PropValue $prop 'startingAnimation')"

        if ($position.Count -lt 2) { $position = @(0, 0) }
        if ($scale.Count -lt 2) { $scale = @(1, 1) }
        if ($scroll.Count -lt 2) { $scroll = @(1, 1) }

        $object = [ordered]@{
            name = $name
            x = [double]$position[0]
            y = [double]$position[1]
            scale = @([double]$scale[0], [double]$scale[1])
            scroll = @([double]$scroll[0], [double]$scroll[1])
        }

        $alpha = Get-PropValue $prop 'alpha'
        if ($null -ne $alpha) { $object.alpha = [double]$alpha }
        $angle = Get-PropValue $prop 'angle'
        if ($null -ne $angle) { $object.angle = [double]$angle }
        $flipX = Get-PropValue $prop 'flipX'
        if ($null -ne $flipX) { $object.flipX = [bool]$flipX }
        $flipY = Get-PropValue $prop 'flipY'
        if ($null -ne $flipY) { $object.flipY = [bool]$flipY }

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
                    offsets = @(0, 0)
                }
            }
            if (-not [string]::IsNullOrWhiteSpace($startingAnimation)) {
                $object.firstAnimation = $startingAnimation
            }
        }
        else {
            $object.type = 'sprite'
            $object.image = $assetPath
        }

        $objects += $object
    }

    $stage = [ordered]@{
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

    return $stage
}

function Get-SourceScriptPath {
    param(
        [string]$Folder,
        [string]$BaseName
    )

    foreach ($ext in @('.hx', '.hxc')) {
        $candidate = Join-Path $Folder ($BaseName + $ext)
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }
    return $null
}

function Should-OverwriteGeneratedScript {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) { return $true }
    try {
        $content = Get-Content -LiteralPath $Path -Raw
        return $content.Contains('Auto-generated by import-funkin-to-psych.ps1')
    } catch {
        return $false
    }
}

function Get-PreservedManualScripts {
    param([string]$ModPath)

    $results = @()
    if (-not (Test-Path -LiteralPath $ModPath)) { return @() }

    foreach ($file in @(Get-ChildItem -LiteralPath $ModPath -Recurse -File -Filter '*.hx' -ErrorAction SilentlyContinue)) {
        if (Should-OverwriteGeneratedScript $file.FullName) { continue }

        try {
            $results += [pscustomobject]@{
                RelativePath = $file.FullName.Substring($ModPath.Length).TrimStart('\', '/')
                Content = Get-Content -LiteralPath $file.FullName -Raw
            }
        } catch {
            continue
        }
    }

    return $results
}

function Restore-PreservedManualScripts {
    param(
        [string]$ModPath,
        [object[]]$Scripts
    )

    foreach ($script in @($Scripts)) {
        $targetPath = Join-Path $ModPath $script.RelativePath
        $targetDir = Split-Path -Parent $targetPath
        if (-not [string]::IsNullOrWhiteSpace($targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        $script.Content | Set-Content -LiteralPath $targetPath -Encoding UTF8
    }
}

function Sync-GooeyQtDependency {
    param([string]$DestinationRoot)

    $gooeyRoot = Join-Path $DestinationRoot 'FNF Gooey Mix'
    $qtRoot = Join-Path $DestinationRoot 'qt-rewired-pc_48d1f'
    if (-not (Test-Path -LiteralPath $gooeyRoot) -or -not (Test-Path -LiteralPath $qtRoot)) { return }

    $copyPairs = @(
        @{ Source = (Join-Path $qtRoot 'stages\qtStagePico.json'); Destination = (Join-Path $gooeyRoot 'stages\qtStagePico.json') },
        @{ Source = (Join-Path $qtRoot 'stages\QtStagePico.hx'); Destination = (Join-Path $gooeyRoot 'stages\QtStagePico.hx') },
        @{ Source = (Join-Path $qtRoot 'stages\qtStage.json'); Destination = (Join-Path $gooeyRoot 'stages\qtStage.json') },
        @{ Source = (Join-Path $qtRoot 'stages\QtStage.hx'); Destination = (Join-Path $gooeyRoot 'stages\QtStage.hx') }
    )

    foreach ($pair in $copyPairs) {
        if (-not (Test-Path -LiteralPath $pair.Source)) { continue }
        $targetDir = Split-Path -Parent $pair.Destination
        if (-not [string]::IsNullOrWhiteSpace($targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $pair.Source -Destination $pair.Destination -Force
    }
}

function Get-ChartNoteTypes {
    param([string]$SongDataRoot)

    $types = @{}
    if (-not (Test-Path -LiteralPath $SongDataRoot)) { return @() }

    $chartFiles = @(Get-ChildItem -LiteralPath $SongDataRoot -File -Filter '*.json' | Where-Object { $_.Name -ne 'events.json' })
    foreach ($chartFile in $chartFiles) {
        try {
            $chart = Get-Content -LiteralPath $chartFile.FullName -Raw | ConvertFrom-Json
        } catch {
            continue
        }

        $sections = Get-PropValue $chart 'notes'
        if ($null -eq $sections) { continue }

        foreach ($section in @($sections)) {
            foreach ($note in @($section.sectionNotes)) {
                if ($note.Count -ge 4 -and -not [string]::IsNullOrWhiteSpace("$($note[3])")) {
                    $types["$($note[3])"] = $true
                }
            }
        }
    }

    return @($types.Keys | Sort-Object)
}

function Get-ChartEventNames {
    param([string]$SongDataRoot)

    $eventsPath = Join-Path $SongDataRoot 'events.json'
    $names = @{}
    if (-not (Test-Path -LiteralPath $eventsPath)) { return @() }

    try {
        $eventsJson = Get-Content -LiteralPath $eventsPath -Raw | ConvertFrom-Json
    } catch {
        return @()
    }

    foreach ($eventRow in @($eventsJson.events)) {
        $rowValue = $eventRow
        if ($eventRow -is [PSCustomObject] -and $eventRow.PSObject.Properties['value']) {
            $rowValue = $eventRow.value
        }

        $eventInfo = $null
        if ($rowValue -is [System.Array] -and $rowValue.Count -gt 1) {
            $eventInfo = $rowValue[1]
        }

        if ($eventInfo -is [PSCustomObject] -and $eventInfo.PSObject.Properties['value']) {
            $eventInfo = $eventInfo.value
        }

        if ($eventInfo -is [System.Array] -and $eventInfo.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace("$($eventInfo[0])")) {
            $names["$($eventInfo[0])"] = $true
        }
    }

    return @($names.Keys | Sort-Object)
}

$repoRoot = Resolve-NormalPath (Join-Path $PSScriptRoot '..')
$sourceRoot = Resolve-NormalPath $SourceRoot
$modsSource = Join-Path $sourceRoot 'mods'
$destinationRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\example_mods'))
if (-not (Test-Path -LiteralPath $modsSource)) {
    throw "Could not find mods folder at $modsSource"
}

New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null

$mods = @(Get-ChildItem -LiteralPath $modsSource -Directory | Sort-Object Name)
$enabledMods = @()
$reportLines = @(
    '# Funkin Port Report',
    '',
    'Imported content was copied from `funkin-windows-64bit\mods` into Psych Engine `example_mods`.',
    '',
    'Notes:',
    '- Raw mod files were preserved.',
    '- V-Slice chart pairs were converted into Psych chart JSONs under each mod `data/<song-id>/` folder.',
    '- Placeholder week files were generated so songs show up in Story/Freeplay.',
    '- Placeholder character/stage JSONs were generated only when Psych-native ones were missing.',
    '- Compatibility `.hx` stubs were generated for songs, characters, stages, custom events, and custom note types.',
    '- Original `.hxc` / source-side scripts were copied for manual follow-up, but they are not auto-translated to Psych gameplay scripts.',
    ''
)

foreach ($mod in $mods) {
    $sourceModPath = $mod.FullName
    $destModPath = Join-Path $destinationRoot $mod.Name
    $preservedManualScripts = @(Get-PreservedManualScripts -ModPath $destModPath)
    if (Test-Path -LiteralPath $destModPath) {
        Remove-Item -LiteralPath $destModPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $destModPath -Force | Out-Null

    foreach ($rootFile in Get-ChildItem -LiteralPath $sourceModPath -File) {
        Copy-Item -LiteralPath $rootFile.FullName -Destination (Join-Path $destModPath $rootFile.Name) -Force
    }

    foreach ($rootDir in Get-ChildItem -LiteralPath $sourceModPath -Directory) {
        $destChild = Join-Path $destModPath $rootDir.Name
        switch -Regex ($rootDir.Name) {
            '^data$' {
                Copy-Item -LiteralPath $rootDir.FullName -Destination $destChild -Recurse -Force
            }
            '^songs$' {
                New-Item -ItemType Directory -Path $destChild -Force | Out-Null
            }
            default {
                New-Item -ItemType Junction -Path $destChild -Target $rootDir.FullName | Out-Null
            }
        }
    }

    $enabledMods += $mod.Name

    $metaPath = Join-Path $destModPath '_polymod_meta.json'
    $polymodMeta = $null
    if (Test-Path -LiteralPath $metaPath) {
        $polymodMeta = Get-Content -LiteralPath $metaPath -Raw | ConvertFrom-Json
    }

    $pack = [ordered]@{
        name = $(if ($null -ne $polymodMeta) { "$($polymodMeta.title)" } else { $mod.Name })
        description = $(if ($null -ne $polymodMeta) { "$($polymodMeta.description)" } else { "Imported from $($mod.Name)" })
        restart = $false
        runsGlobally = $true
        color = @(146, 113, 253)
    }
    $pack | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $destModPath 'pack.json') -Encoding UTF8

    $weeksRoot = Join-Path $destModPath 'weeks'
    New-Item -ItemType Directory -Path $weeksRoot -Force | Out-Null
    $charactersRoot = Join-Path $destModPath 'characters'
    $stageScriptsRoot = Join-Path $destModPath 'stages'
    $customEventsRoot = Join-Path $destModPath 'custom_events'
    $customNoteTypesRoot = Join-Path $destModPath 'custom_notetypes'
    New-Item -ItemType Directory -Path $charactersRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $stageScriptsRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $customEventsRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $customNoteTypesRoot -Force | Out-Null

    $weekNames = @()
    $songImports = @()
    $songScriptMap = @{}

    $metadataFiles = @(Get-ChildItem -LiteralPath (Join-Path $destModPath 'data\songs') -Recurse -File -Filter '*-metadata*.json' -ErrorAction SilentlyContinue | Sort-Object FullName)
    foreach ($metadataFile in $metadataFiles) {
        $songFolder = Split-Path -Parent $metadataFile.FullName
        $songIdBase = Split-Path -Leaf $songFolder
        $metadataBaseName = [System.IO.Path]::GetFileNameWithoutExtension($metadataFile.Name)
        $chartBaseName = $metadataBaseName -replace '-metadata', '-chart'
        $chartPath = Join-Path $songFolder "$chartBaseName.json"
        if (-not (Test-Path -LiteralPath $chartPath)) {
            continue
        }

        $suffix = $metadataBaseName.Substring(($songIdBase + '-metadata').Length).TrimStart('-')
        $psychSongId = if ([string]::IsNullOrWhiteSpace($suffix)) {
            Format-SongPath $songIdBase
        } else {
            "$(Format-SongPath $songIdBase)-$(Format-SongPath $suffix)"
        }

        $metadataPreview = Get-Content -LiteralPath $metadataFile.FullName -Raw | ConvertFrom-Json
        $songDisplay = if ([string]::IsNullOrWhiteSpace($suffix)) {
            "$($metadataPreview.songName)"
        } else {
            "$($metadataPreview.songName) ($suffix)"
        }

        $converted = Convert-VSliceToPsych -ChartPath $chartPath -MetadataPath $metadataFile.FullName -PsychSongId $psychSongId -DisplayName $songDisplay
        $psychDataRoot = Join-Path $destModPath "data\$psychSongId"
        New-Item -ItemType Directory -Path $psychDataRoot -Force | Out-Null

        foreach ($diff in $converted.Difficulties.Keys) {
            $fileName = "$psychSongId$(Get-DifficultyFileSuffix $diff).json"
            $converted.Difficulties[$diff] | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $psychDataRoot $fileName) -Encoding UTF8
        }

        if ($converted.Events.events.Count -gt 0) {
            $converted.Events | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $psychDataRoot 'events.json') -Encoding UTF8
        }

        $psychSongsRoot = Join-Path $destModPath "songs\$psychSongId"
        New-Item -ItemType Directory -Path $psychSongsRoot -Force | Out-Null

        $convertedCharacters = $converted.Metadata.playData.characters
        $playerCharacter = "$(Get-PropValue $convertedCharacters 'player')"
        $opponentCharacter = "$(Get-PropValue $convertedCharacters 'opponent')"
        $girlfriendCharacter = "$(Get-PropValue $convertedCharacters 'girlfriend')"
        if ([string]::IsNullOrWhiteSpace($playerCharacter)) { $playerCharacter = 'bf' }
        if ([string]::IsNullOrWhiteSpace($opponentCharacter)) { $opponentCharacter = 'dad' }
        if ([string]::IsNullOrWhiteSpace($girlfriendCharacter)) { $girlfriendCharacter = 'gf' }

        $sourceSongAudio = Join-Path $sourceModPath "songs\$songIdBase"
        if (Test-Path -LiteralPath $sourceSongAudio) {
            $inst = Get-InstCandidate -SongFolder $sourceSongAudio -VariantSuffix (Format-SongPath $suffix)
            if ($null -ne $inst) {
                Copy-Item -LiteralPath $inst.FullName -Destination (Join-Path $psychSongsRoot 'Inst.ogg') -Force
            }

            $voiceMatch = Get-VoiceMatches -SongFolder $sourceSongAudio -VariantSuffix (Format-SongPath $suffix) -PlayerCharacter $playerCharacter -OpponentCharacter $opponentCharacter
            if ($null -ne $voiceMatch.Combined) {
                Copy-Item -LiteralPath $voiceMatch.Combined.FullName -Destination (Join-Path $psychSongsRoot 'Voices.ogg') -Force
            }
            if ($null -ne $voiceMatch.Player) {
                Copy-Item -LiteralPath $voiceMatch.Player.FullName -Destination (Join-Path $psychSongsRoot 'Voices-Player.ogg') -Force
            }
            if ($null -ne $voiceMatch.Opponent) {
                Copy-Item -LiteralPath $voiceMatch.Opponent.FullName -Destination (Join-Path $psychSongsRoot 'Voices-Opponent.ogg') -Force
            }
        }

        Ensure-PlaceholderCharacter -RepoRoot $repoRoot -ModRoot $destModPath -CharacterName $playerCharacter -Role 'player'
        Ensure-PlaceholderCharacter -RepoRoot $repoRoot -ModRoot $destModPath -CharacterName $opponentCharacter -Role 'opponent'
        Ensure-PlaceholderCharacter -RepoRoot $repoRoot -ModRoot $destModPath -CharacterName $girlfriendCharacter -Role 'girlfriend'
        Ensure-PlaceholderStage -ModRoot $destModPath -StageName (Convert-StageName "$($converted.Metadata.playData.stage)")

        $weekName = "port-$(Format-SongPath $psychSongId)"
        Write-WeekFile -WeeksRoot $weeksRoot -WeekName $weekName -SongDisplay $songDisplay -SongId $psychSongId `
            -Opponent $opponentCharacter -Player $playerCharacter `
            -Girlfriend $girlfriendCharacter -Difficulties @($converted.Metadata.playData.difficulties) `
            -ModTitle $pack.name
        $weekNames += $weekName
        $songImports += $psychSongId
        $songScriptMap[$psychSongId] = $songIdBase
    }

    if ($weekNames.Count -gt 0) {
        ($weekNames -join [Environment]::NewLine) | Set-Content -LiteralPath (Join-Path $weeksRoot 'weekList.txt') -Encoding UTF8
    }

    $sourceStageDataRoot = Join-Path $destModPath 'data\stages'
    if (Test-Path -LiteralPath $sourceStageDataRoot) {
        foreach ($sourceStageDataFile in Get-ChildItem -LiteralPath $sourceStageDataRoot -File -Filter '*.json') {
            try {
                $sourceStageData = Get-Content -LiteralPath $sourceStageDataFile.FullName -Raw | ConvertFrom-Json
            } catch {
                continue
            }
            if ($null -eq $sourceStageData) { continue }

            $stageName = [System.IO.Path]::GetFileNameWithoutExtension($sourceStageDataFile.Name)
            $existingStageFilePath = Join-Path $stageScriptsRoot ($stageName + '.json')
            $existingDirectory = ''
            if (Test-Path -LiteralPath $existingStageFilePath) {
                try {
                    $existingStageJson = Get-Content -LiteralPath $existingStageFilePath -Raw | ConvertFrom-Json
                    $existingDirectory = "$(Get-PropValue $existingStageJson 'directory')"
                } catch {
                    $existingDirectory = ''
                }
            }

            $convertedStage = Convert-SourceStageDataToPsych -StageData $sourceStageData -ExistingDirectory $existingDirectory
            if ($null -eq $convertedStage) { continue }
            $convertedStage | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $existingStageFilePath -Encoding UTF8
        }
    }

    $sourceScriptsRoot = Join-Path $sourceModPath 'scripts'
    $sourceCharacterScripts = Join-Path $sourceScriptsRoot 'characters'
    if (Test-Path -LiteralPath $sourceCharacterScripts) {
        foreach ($script in Get-ChildItem -LiteralPath $sourceCharacterScripts -File) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($script.Name)
            $target = Join-Path $charactersRoot ($baseName + '.hx')
            if (Should-OverwriteGeneratedScript $target) {
                Write-CompatStub -Path $target -Kind 'character' -Name $baseName -SourceScript $script.FullName
            }
        }
    }

    $sourceStageScripts = Join-Path $sourceScriptsRoot 'stages'
    if (Test-Path -LiteralPath $sourceStageScripts) {
        foreach ($script in Get-ChildItem -LiteralPath $sourceStageScripts -File) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($script.Name)
            $target = Join-Path $stageScriptsRoot ($baseName + '.hx')
            if (Should-OverwriteGeneratedScript $target) {
                Write-CompatStub -Path $target -Kind 'stage' -Name $baseName -SourceScript $script.FullName
            }
        }
    }

    $sourceEventScripts = Join-Path $sourceScriptsRoot 'events'
    if (Test-Path -LiteralPath $sourceEventScripts) {
        foreach ($script in Get-ChildItem -LiteralPath $sourceEventScripts -File) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($script.Name)
            $target = Join-Path $customEventsRoot ($baseName + '.hx')
            if (Should-OverwriteGeneratedScript $target) {
                Write-CompatStub -Path $target -Kind 'event' -Name $baseName -SourceScript $script.FullName -TriggerName $baseName
            }
            "Placeholder stub for imported source event script: $baseName" | Set-Content -LiteralPath (Join-Path $customEventsRoot ($baseName + '.txt')) -Encoding UTF8
        }
    }

    $songDataDirs = @(Get-ChildItem -LiteralPath (Join-Path $destModPath 'data') -Directory | Where-Object { $_.Name -notmatch '^songs$' })
    $allNoteTypes = @{}
    $allEventNames = @{}
    foreach ($songDir in $songDataDirs) {
        $songScriptBase = $songScriptMap[$songDir.Name]
        if (-not [string]::IsNullOrWhiteSpace($songScriptBase)) {
            $sourceSongScript = Get-SourceScriptPath -Folder (Join-Path $sourceScriptsRoot 'songs') -BaseName $songScriptBase
            if ($null -ne $sourceSongScript) {
                $songTarget = Join-Path $songDir.FullName 'source-port-song.hx'
                if (Should-OverwriteGeneratedScript $songTarget) {
                    Write-CompatStub -Path $songTarget -Kind 'song' -Name $songDir.Name -SourceScript $sourceSongScript
                }
            }
        }

        foreach ($typeName in @(Get-ChartNoteTypes -SongDataRoot $songDir.FullName)) {
            $allNoteTypes[$typeName] = $true
        }
        foreach ($eventName in @(Get-ChartEventNames -SongDataRoot $songDir.FullName)) {
            $allEventNames[$eventName] = $true
        }
    }

    foreach ($eventName in @($allEventNames.Keys | Sort-Object)) {
        $target = Join-Path $customEventsRoot ($eventName + '.hx')
        if (-not (Test-Path -LiteralPath $target) -or (Should-OverwriteGeneratedScript $target)) {
            $sourceScript = Get-SourceScriptPath -Folder $sourceEventScripts -BaseName $eventName
            if ($null -eq $sourceScript) { $sourceScript = Join-Path $sourceScriptsRoot ('events/' + $eventName + '.hxc') }
            Write-CompatStub -Path $target -Kind 'event' -Name $eventName -SourceScript $sourceScript -TriggerName $eventName
            "Placeholder stub for imported chart event: $eventName" | Set-Content -LiteralPath (Join-Path $customEventsRoot ($eventName + '.txt')) -Encoding UTF8
        }
    }

    foreach ($typeName in @($allNoteTypes.Keys | Sort-Object)) {
        $target = Join-Path $customNoteTypesRoot ($typeName + '.hx')
        $sourceScript = Get-SourceScriptPath -Folder (Join-Path $sourceScriptsRoot 'notestyles') -BaseName $typeName
        if ($null -eq $sourceScript) { $sourceScript = Join-Path $sourceScriptsRoot ('notestyles/' + $typeName + '.hxc') }
        if (Should-OverwriteGeneratedScript $target) {
            Write-CompatStub -Path $target -Kind 'note type' -Name $typeName -SourceScript $sourceScript
        }
        "Placeholder stub for imported note type: $typeName" | Set-Content -LiteralPath (Join-Path $customNoteTypesRoot ($typeName + '.txt')) -Encoding UTF8
    }

    Restore-PreservedManualScripts -ModPath $destModPath -Scripts $preservedManualScripts

    $reportLines += "## $($pack.name)"
    $reportLines += ''
    $reportLines += ('- Source folder: `mods/' + $mod.Name + '`')
    $reportLines += ('- Generated songs: ' + $songImports.Count)
    $reportLines += ('- Generated weeks: ' + $weekNames.Count)
    $reportLines += '- Placeholder Psych character files are only fallbacks. Custom character behavior still needs manual porting from the copied scripts.'
    $reportLines += '- Safe Psych HScript placeholders were generated for the load points Psych recognizes so missing scripts are visible in-game instead of failing silently.'
    $reportLines += '- Large asset folders were linked into `example_mods` with NTFS junctions to avoid duplicating the original build on disk.'
    $reportLines += ''
}

Sync-GooeyQtDependency -DestinationRoot $destinationRoot

($enabledMods | ForEach-Object { "$_|1" }) -join [Environment]::NewLine | Set-Content -LiteralPath (Join-Path $repoRoot 'list.txt') -Encoding UTF8
$reportLines | Set-Content -LiteralPath (Join-Path $repoRoot 'docs\FUNKIN_PORT_REPORT.md') -Encoding UTF8

Write-Host "Imported $($mods.Count) mods into $destinationRoot"
