# Ce script parcourt un csv de exportify afin de télécharcher une playlist en mp3. 
# il est possible qu'il y ait besoin de plusieurs jours pour les grosse playlist à cause de limite de l'api de youtube
#
#ce script necessite :
#   - yt-dlp.exe (https://github.com/yt-dlp/yt-dlp#installation)
#   - ffmpeg (choco install ffmpeg) via chocolatey (https://chocolatey.org/install)
#   - clé api youtube (console google)


# set your api key here (https://console.cloud.google.com/apis/library/youtube.googleapis.com)
$Global:YT_API_KEY = "[REDACTED]"



#This function browse youtube and return the first result of $query in the form of the video link
Function Search-YouTube($query ) {
 
    $params = @{
        type       = 'video';
        q          = "$query";
        part       = 'snippet';
        maxResults = "1";
        key        = "$Global:YT_API_KEY"  
    }   
    $response = $null
    $response = Invoke-RestMethod -Uri https://www.googleapis.com/youtube/v3/search -Body $params -Method Get
    for ( $i = 1; $i -le $response.items.count; $i++) {
        #affiche les infos trouvées
        Write-Host "Found : $($response.items[$i-1].snippet.title)" -ForegroundColor Green
        $url = "https://www.youtube.com/watch?v=$($response.items[$i-1].id.videoid)"
        Write-Host $url -ForegroundColor Blue
        return $url
    }
   
}



#see https://github.com/mossrich/PowershellRecipes/blob/master/ID3v1-Edit.ps1 
#Set the specified ID3v1 properties of a file by writing the last 128 bytes
#this function allow to set the mp3 tags
Function Set-ID3v1( #All parameters except path are optional, they will not change if not specified. 
    [string]$path, #Full path to the file to be updated - wildcards not supported because [] are so stinky and it's only supposed to work on one file at a time. 
    [string]$Title = "`0", #a string containing only 0 indicates a parameter not specified. 
    [string]$Artist = "`0",
    [string]$Album = "`0",
    [string]$Year = "`0",
    [string]$Comment = "`0",
    [int]$Track = -1,
    [int]$Genre = -1, 
    [bool]$BackDate = $true) {
    #Preserve modification date, but add a minute to indicate it's newer than duplicates
    $CurrentModified = (Get-ChildItem -LiteralPath $path).LastWriteTime #use literalpath here to get only one file, even if it has []
    Try {
        $enc = [System.Text.Encoding]::ASCII #Probably wrong, but works occasionally. See https://stackoverflow.com/questions/9857727/text-encoding-in-id3v2-3-tags
        $currentID3Bytes = New-Object byte[] (128)
        $strm = New-Object System.IO.FileStream ($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        $strm.Seek(-128, 'End') | Out-Null #Basic ID3v1 info is 128 bytes from EOF
        $strm.Read($currentID3Bytes, 0, $currentID3Bytes.Length) | Out-Null
       
        $strm.Seek(-128, 'End') | Out-Null #Basic ID3v1 info is 128 bytes from EOF
        If ($enc.GetString($currentID3Bytes[0..2]) -ne 'TAG') {
           
            $strm.Seek(0, 'End') 
            $currentID3Bytes = $enc.GetBytes(('TAG' + (' ' * (30 + 30 + 30 + 4 + 30)))) #Add a blank tag to the end of the file
            $currentID3Bytes += 255 #empty Genre
            $strm.Write($currentID3Bytes, 0, $currentID3Bytes.length)
            $strm.Flush()
            $Strm.Close()
            $strm = New-Object System.IO.FileStream ($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            $strm.Seek(-128, 'End') 
        } 
        $strm.Seek(3, 'Current') | Out-Null #skip over 'TAG' to get to the good stuff
        If ($Title -eq "`0") { $strm.Seek(30, 'Current') | Out-Null } #Skip over
        Else { $strm.Write($enc.GetBytes($Title.PadRight(30, ' ').Substring(0, 30)), 0, 30) } #if specified, write 30 space-padded bytes to the stream
        If ($Artist -eq "`0") { $strm.Seek(30, 'Current') | Out-Null } 
        Else { $strm.Write($enc.GetBytes($Artist.PadRight(30, ' ').Substring(0, 30)), 0, 30) }
        If ($Album -eq "`0") { $strm.Seek(30, 'Current') | Out-Null } 
        Else { $strm.Write($enc.GetBytes($Album.PadRight(30, ' ').Substring(0, 30)), 0, 30) }
        If ($Year -eq "`0") { $strm.Seek(4, 'Current') | Out-Null } 
        Else { $strm.Write($enc.GetBytes($Year.PadRight(4, ' ').Substring(0, 4)), 0, 4) }
        If (($Track -ne -1) -or ($currentID3Bytes[125] -eq 0)) { $CommentMaxLen = 28 }Else { $CommentMaxLen = 30 } #If a Track is specified or present in the file, Comment is 28 chars
        If ($Comment -eq "`0") { $strm.Seek($CommentMaxLen, 'Current') | Out-Null } 
        Else { $strm.Write($enc.GetBytes($Comment.PadRight($CommentMaxLen, ' ').Substring(0, $CommentMaxLen)), 0, $CommentMaxLen) }
        If ($Track -eq -1 ) { $strm.Seek(2, 'Current') | Out-Null }
        Else { $strm.Write(@(0, $Track), 0, 2) } #Track, if present, is preceded by a 0-byte to form the last two bytes of Comment
        If ($Genre -ne -1) { $strm.Write($Genre, 0, 1) | Out-Null } 
    }
    Catch {
        Write-Error $_.Exception.Message
    }
    Finally {
        If ($strm) {
            $strm.Flush()
            $strm.Close()
        }
    }
    If ($BackDate) { (Get-ChildItem -LiteralPath $path).LastWriteTime = $CurrentModified.AddMinutes(1) }
}


#this function display the mp3 tags in the console. 
#not used
Function Get-ID3v1(
    [parameter(ValueFromPipeline)]
    [string]$path = "") {
    #Parses the last 128 bytes from an MP3 file 
    Process {
        $buf = New-Object byte[] (128)
        $strm = [System.IO.File]::OpenRead($path) #https://stackoverflow.com/questions/44462561/system-io-streamreader-vs-get-content-vs-system-io-file
        $strm.Seek( - ($buf.Length), [System.IO.SeekOrigin]::End) | Out-Null #ID3 bytes are at EOF
        $strm.Read($buf, 0, $buf.Length) | Out-Null
        $strm.Close()
        $st = ([System.Text.Encoding]::ASCII).GetString($buf)
        If ($st.Substring(0, 3) -ne 'TAG') { Throw "No ID3v1 tag found in $path" }
        $ID3v1 = [ordered]@{}
        $ID3v1['Path'] = $path
        $ID3v1['Title'] = $st.Substring(3, 30)
        $ID3v1['Artist'] = $st.Substring(33, 30)
        $ID3v1['Album'] = $st.Substring(63, 30)
        $ID3v1['Year'] = $st.Substring(93, 4)
        If ($buf[125] -eq 0) {
            $ID3v1['Comment'] = $st.Substring(97, 28)
            $ID3v1['Track'] = $buf[126]
        }
        Else {
            $ID3v1['Comment'] = $st.Substring(97, 30)
            $ID3v1['Track'] = ""
        }
        $ID3v1['Genre'] = $buf[127]
        $ID3v1
    }
}
# examples for the mp3 tags functions
#Set-ID3v1 -path ".\Nothing But Thieves - Forever & Ever More.mp3" -Year 2018 -Title "Forever & Ever More" -Artist "Nothing But Thieves"
#Get-ID3v1 -path '.\Nothing But Thieves - Forever & Ever More.mp3'





#here the stuff happens
try {
    #importe le premier csv trouvé dans PSScriptRoot
    $csv = Import-Csv (Get-ChildItem -filter *.csv)[0] 
    $totalCount = Get-Content (Get-ChildItem -filter *.csv)[0] | Measure-Object -Line | Select-Object -ExpandProperty Lines
    $currentCount = 1
    foreach ($_ in $csv) {
        $currentCount++
        
        $song = ("$($_."Artist Name(s)".split(",")[0]) - $($_."Track Name")")

        #les caractères interdit dans les nom de fichiers sont supprimés.   
        $song = ($song -replace '\<|\>|:|"|/|\\|\||\?|\*', '')

        Write-Host "`n Searching for $song" -ForegroundColor Magenta
    
        if (Test-Path -Path "$PSScriptRoot\songs\$song.mp3" -PathType Leaf) {
            Write-Host "File exists. Skipping..."
        }
        else {
            try {
                
                $searchURL = Search-YouTube($song)
                # Process the response here
                Write-Host "Downloading & Extracting audio... "
                yt-dlp.exe -x  --audio-format mp3 $searchURL -P $PSScriptRoot\songs -o $song -q  --no-warnings

                #set mp3 tags according to the csv
                Write-Host "Setting MP3 tags... "
                Set-ID3v1 -path "$PSScriptRoot\songs\$song.mp3" -Year "$($($_."Release Date").split("-")[0])" -Title "$($_."Track Name")" -Artist "$($_."Artist Name(s)")" -Album "$($_."Album Name")"
            }
            catch {
                Write-Host -ForegroundColor Red "Error - Something's missing or the API is at it's limits (max queries for today) `n Rerun the sript tomorow or find a solution and tell me"
                pause
                break

            }
        }
        # Update progress
        $percentComplete = ($currentCount / $totalCount) * 100
        $status = "Processing item $currentCount of $totalCount"
        Write-Progress -Activity "Processing CSV" -Status $status -PercentComplete $percentComplete
    }
}
catch {
    Write-Host "Failed to import CSV file. Error: $($_.Exception.Message)" -ForegroundColor Red
    $url = "https://exportify.net/#playlists"

    Write-Host "Please login to Spotify here: $url `n And put the downloaded csv in the same folder as the script"
    Pause
}