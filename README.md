# Spotify2mp3
ce script permet (plus ou moins facilement) de  télécharcher votre playlist spotify préférée
# Setup 
1. télécharger yt-dlp.exe pour pouvoir télécharcher des vidéos depuis youtube 
2. installer ffmpeg (avec chocolatey)
3. se créer une clé d'API pour pouvoir rechercher sur youtube (https://console.cloud.google.com/apis/library/youtube.googleapis.com) et la mettre dans le script ($Global:YT_API_KEY) seule modification necessaire
4. se loguer sur https://exportify.net/#playlists et télécharger le csv de la playlist à télécharger


## Commandes (administrateur)
---
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install ffmpeg
---

### Structures des fichiers
une fois tout mis en place, les fichiers devraient ressembler plus ou moins à ça.
---
└───Spotify2mp3
    │   songs.csv
    │   Spotify2MP3.ps1
    │   yt-dlp.exe
    │
    └───songs
        |
        ...
---