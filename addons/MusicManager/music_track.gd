class_name MusicTrack
extends Resource

## Name for the song
@export var name: String = ""

## Artist's name for the song
@export var artist: String = ""

## Audiostream file for the song: .ogg or .wav are recommended with Godot. Other file types may work but are not recommended.
@export var track: AudioStream

@export var trackNum: int = 0

@export var coverArt: Texture2D
