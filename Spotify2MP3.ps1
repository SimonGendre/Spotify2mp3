$musicDir = "B:\Audio\music"

# Capture the start time
$StartTime = Get-Date

#download the playlists
Set-Location "$musicDir\Playlists"
$fileContent = Get-Content -Path "$PSScriptRoot\playlists.txt" -Encoding UTF8

$fileContent | ForEach-Object {
    
    $line = $_.Trim()
   

    if (!($line.StartsWith("#"))) {
        $name = $($line -split (";"))[0]
        $url = $($line -split (";"))[1]
        Write-Host "Downloading: $name"
        if (!(Test-Path -Type Container $musicDir\Playlists\$name)) {
            mkdir $musicDir\Playlists\$name
        }
        Set-Location $musicDir\Playlists\$name
        python.exe -m spotdl --user-auth --overwrite "skip" $($url)
        Set-Location $musicDir
    }
}


#download the music
Set-Location "$musicDir\Music"
$fileContent = Get-Content -Path "$PSScriptRoot\2DL.txt" -Encoding UTF8

$spotdlInstruction = "spotdl --user-auth --overwrite 'skip' download "

$fileContent | ForEach-Object {
    $line = $_.Trim()
    if (!($line.StartsWith("#"))) {
        
        $spotdlInstruction += "$line "
               
        # Replace the existing line with a modified one (with "#" added)
        #(Get-Content -Path "$PSScriptRoot\2DL.txt" -Raw) -replace [regex]::Escape($line), "#$line" | Set-Content -Path "$PSScriptRoot\2DL.txt"
    }
}
powershell.exe $spotdlInstruction


# Checks for duplicates between albums and playlists
$playlistsDir = "$musicDir\Playlists\"
$musicpath = "$musicDir\Music\"

$musicFiles = Get-ChildItem -Path $musicpath -Recurse
$playlistFiles = Get-ChildItem -Path $playlistsDir -Recurse

foreach ($song in $playlistFiles) {
    $baseName = $song.BaseName
    $matchingMusicFile = $musicFiles | Where-Object { $_.BaseName -eq $baseName }

    if ($matchingMusicFile) {
        Write-Host "Duplicate $baseName" -ForegroundColor Red
        Remove-Item $matchingMusicFile.FullName
    }
}





# Capture the end time
$EndTime = Get-Date

# Calculate elapsed time
$ElapsedTime = New-TimeSpan -Start $StartTime -End $EndTime

# Display the elapsed time
Write-Host "Script execution took $($ElapsedTime.Hours) hours, $($ElapsedTime.Minutes) minutes, and $($ElapsedTime.Seconds) seconds."
Pause