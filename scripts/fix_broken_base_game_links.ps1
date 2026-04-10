$base = Resolve-Path "assets\base_game"
$backup = "scripts\broken_links_backup"

Write-Host "Base dir: $base"
Write-Host "Backup root: $backup"

if (!(Test-Path $base)) {
    Write-Host "Base directory missing: $base"
    exit 1
}

New-Item -ItemType Directory -Force -Path $backup | Out-Null

$moved = @()
$errors = @()

Get-ChildItem $base | ForEach-Object {
    $child = $_.FullName
    $name = $_.Name

    if (!(Test-Path $child)) {
        $errors += "$name does not exist"
        return
    }

    if ($_.PSIsContainer) {
        try {
            Get-ChildItem $child | Out-Null
            # listed OK
        } catch {
            # Treat as broken junction/link; move to backup
            $dest = Join-Path $backup $name
            try {
                Move-Item $child $dest
                $moved += "$name -> $dest"
                Write-Host "Moved broken entry: $child -> $dest"
            } catch {
                $errors += "$name move failed: $($_.Exception.Message)"
            }
        }
    }
}

Write-Host "`nSummary:"
Write-Host "Moved: $($moved.Count)"
$moved | ForEach-Object { Write-Host " - $_" }

if ($errors.Count -gt 0) {
    Write-Host "`nErrors:"
    $errors | ForEach-Object { Write-Host " - $_" }
} else {
    Write-Host "No errors."
}