param(
    [Parameter()]
    [string]$musicDir,

    [Parameter()]
    [string]$playlistsFile,

    [Parameter()]
    [string]$2dlFile,

    [Parameter()]
    [switch]$OverwriteExisting
)

# Default values for parameters
$defaultMusicDir = "B:\Audio\music"
$defaultPlaylistsFile = "$PSScriptRoot\playlists.txt"
$default2dlFile = "$PSScriptRoot\2DL.txt"

# Set default values if parameters are not provided
if (-not $musicDir) {
    $musicDir = $defaultMusicDir
}

if (-not $playlistsFile) {
    $playlistsFile = $defaultPlaylistsFile
}

if (-not $2dlFile) {
    $2dlFile = $default2dlFile
}

# Display script start time
$StartTime = Get-Date

# Create necessary directories if not exist
$directories = @("$musicDir\Playlists", "$musicDir\Music", "$PSScriptRoot\syncFiles")
foreach ($directory in $directories) {
    if (!(Test-Path -Type Container $directory)) {
        Write-Host -ForegroundColor Cyan "$directory directory not found. Creating..."
        $null = New-Item -Path $directory -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
}

# Remove old music if OverwriteExisting switch is set
if ($OverwriteExisting) {
    Write-Host -ForegroundColor Red "Script is set to overwrite existing data. Removing old mp3..."
    Remove-Item -Recurse "$musicDir\Music\*", "$musicDir\Playlists\*"
}

# Download playlists
Set-Location "$musicDir\Playlists"
$fileContent = Get-Content -Path $playlistsFile -Encoding UTF8

$fileContent | ForEach-Object {
    $line = $_.Trim()
    if (-not $line.StartsWith("#")) {
        $name, $url = $line -split ";"
        Write-Host "Downloading playlist: $name" -ForegroundColor Cyan
        if (!(Test-Path -Type Container "$musicDir\Playlists\$name")) {
            Write-Host -ForegroundColor Cyan "$name directory not found. Creating..."
            $null = New-Item -Path "$musicDir\Playlists\$name" -ItemType Directory -Force -ErrorAction SilentlyContinue
        }
        Set-Location "$musicDir\Playlists\$name"
        spotdl --user-auth --overwrite "skip" --save-file "$PSScriptRoot\syncFiles\$name.spotdl" sync $url
        Set-Location $musicDir
    }
}

# Download music in global music folder
Write-Host -ForegroundColor Cyan "Playlists finished downloading. Starting bulk music download..."
Set-Location "$musicDir\Music"
$fileContent = Get-Content -Path $2dlFile -Encoding UTF8

$spotdlInstruction = "spotdl --user-auth --overwrite 'skip' --save-file '$PSScriptRoot\syncFiles\bulk.spotdl' sync "
$fileContent | ForEach-Object {
    $line = $_.Trim()
    if (-not $line.StartsWith("#")) {
        $spotdlInstruction += "$line "
    }
}
powershell.exe $spotdlInstruction

# Check for duplicates between albums and playlists
$playlistsDir = "$musicDir\Playlists\"
$musicpath = "$musicDir\Music\"

$musicFiles = Get-ChildItem -Path $musicpath -Recurse
$playlistFiles = Get-ChildItem -Path $playlistsDir -Recurse

foreach ($song in $playlistFiles) {
    $baseName = $song.BaseName
    $matchingMusicFile = $musicFiles | Where-Object { $_.BaseName -eq $baseName }

    if ($matchingMusicFile) {
        Write-Host "Duplicate $baseName" -ForegroundColor Red
        try {
            Remove-Item $matchingMusicFile.FullName -ErrorAction SilentlyContinue
        }
        catch {
            # Ignore any errors while removing duplicate files
        }
    }
}

Set-Location $PSScriptRoot

# Display script end time and execution duration
$EndTime = Get-Date
$ElapsedTime = New-TimeSpan -Start $StartTime -End $EndTime
Write-Host "Script execution took $($ElapsedTime.Hours) hours, $($ElapsedTime.Minutes) minutes, and $($ElapsedTime.Seconds) seconds."
Pause