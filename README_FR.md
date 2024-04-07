# Spotify2mp3
ce script permet (plus ou moins facilement) de  télécharcher votre playlist spotify préférée
# Setup 
1. Ce script fonctionne grâce à [spotdl](https://github.com/spotDL/spotify-downloader). Il faudra donc s'assurer qu'il est installé.
2. Il faudra ensuite définir les playlists, albums, musiques etc... à télécharger. Pour cela, les deux fichiers textes devront être modifiés.

## playlists.txt
Ce fichiers permet de télécharger des playlists (ou autres, hein) en les organisant dans des dossiers (à contrario de 2DL.txt). La syntaxe est la suivante :

```plaintext
NomDuDossier;lienSpotify
#Par exemple :
PlugNRock;https://open.spotify.com/playlist/5XkjIzp66gB9nh7N6QjFbl
```
Le script va d'abord créer le dossier puis va y mettre toutes les musiques de la playlist/album. Il n'y a pas de limites de dossier so enjoy :)

## 2DL.txt
2DL.txt permet de spécifier les trucs à télécharger sans les trier. Tout ce qui est mit ici sera télécharger dans le dossier "Music" (sans doublons). les liens peuvent être mis sans ordre spécifique, ils seront tous traiter à un moment ou un autre. les lignes qui commencent par "#" sont considérées comme des commentaires et ne sont pas lues (comme la doc en général). Voici un exemple avec un seul lien, si tu veux le gros exemple regarde le fichier directement.

```plaintext
#Outer Wilds (Original Soundtrack)
https://open.spotify.com/album/1U0A6RPNJB05PtuBcaTM7o
```

# Fonctionnement 
Avant de lancer le script, il va falloir définir $musicDir (première ligne) afin de préciser le dossier dans lequel les musiques seront ~~piratées~~téléchargées. Le script se chargera alors de créer les bon dossier et d'y mettre la bonne musique (Et non pas de la bonne musique si les fichiers texte ne sont pas les miens). Spotdl se chargera de mettre les tags mp3 en fonction de Spotify et de télécharger les mp3 depuis youtube music. 
Une fois que tout est téléchargé, le script va supprimer tout les fichiers qui sont à double entre Playlists et Music, seule la version de Playlists est gardée. De cette manière, il y a qu'un seul de chaque fichier. 

```
$musicDir
|-- Playlists
|   |-- Dossier1
|   |   |-- beaucoupDeFichiers.mp3
|   |
|   |-- LaDanceDesCanards
|       |-- beaucoupDeFichiers.mp3
|
|-- Music
    |-- beaucoupDeFichiers.mp3



```

