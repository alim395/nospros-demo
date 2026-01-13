extends Node

enum TaskThemes {Luna, OliveGreen, Embedded, ZunaRoyaleNoir}
enum buttonStyle {Classic, Y2K}

@export var skipWelcome : bool
@export var highFidelity : bool
@export var crtFilter : bool
@export var defaultTheme : TaskThemes
@export var defaultWallpaperIndex : int
@export var defaultButtonStyle : buttonStyle
var errorCount : int
var trollMode := false

@export var playerName := "Adam"
@export var playerUser := "AdamZT395"
@export var playerPFP : Texture2D

signal GetTrolled

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skipWelcome = false
	highFidelity = false
	crtFilter = false
	defaultTheme = TaskThemes.Luna
	defaultButtonStyle = buttonStyle.Classic
	defaultWallpaperIndex = 0
	errorCount = 0
	
	# Resources
	# ProjectSettings.load_resource_pack("res://graphics.pck")
	# ProjectSettings.load_resource_pack("res://audio.pck")
	# get_tree().change_scene_to_file("res://scenes/main.tscn")

func activateTroll() -> void:
	GetTrolled.emit()

func playSFX(sfx : AudioStream) -> void:
	MusicManager.sfx_player.stream = sfx
	MusicManager.sfx_player.play()
