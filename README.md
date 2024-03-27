# Spotify2mp3

This script allows you (more or less easily) to download your favorite Spotify playlist.

## Setup

1. This script works thanks to [spotdl](https://github.com/spotDL/spotify-downloader). Make sure it is installed.
2. You will then need to define the playlists, albums, songs, etc., to download. For that, the two text files must be modified.

### playlists.txt

This file allows you to download playlists (or other things) by organizing them into folders (unlike 2DL.txt). The syntax is as follows:

```
FolderName;SpotifyLink
#For example:
PlugNRock;https://open.spotify.com/playlist/5XkjIzp66gB9nh7N6QjFbl
```
The script will first create the folder and then place all the songs from the playlist/album into it. There is no limit to folders, so enjoy :)

### 2DL.txt

2DL.txt (ToDownload.txt if you haven't understood) specifies items to download without sorting. Everything placed here will be downloaded into the "Music" folder (without duplicates). Links can be added in any order; they will all be processed at some point. Lines starting with "#" are considered comments and are not read (like the documentation in general). Here's an example with a single link; for the comprehensive example, check the file directly.
```
#Outer Wilds (Original Soundtrack)
https://open.spotify.com/album/1U0A6RPNJB05PtuBcaTM7o
```

## Operation

Before running the script, you need to define $musicDir (first line) to specify the folder where the songs will be ~~pirated~~ downloaded. The script will then create the appropriate folders and place the right music in them (not good music if the text files aren't mine). Spotdl will handle tagging MP3s based on Spotify and downloading MP3s from YouTube Music.
When everything is downloaded, the script will remove any songs that appears in the Playlists folder from the Music folder. That way you only have one of each file. 
```
$musicDir
|-- Playlists
|   |-- Folder1
|   |   |-- manyFiles.mp3
|   |
|   |-- GringeMusic
|       |-- manyFiles.mp3
|
|-- Music
    |-- manyFiles.mp3
```

