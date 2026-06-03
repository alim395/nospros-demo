extends Node

enum TaskThemes {Luna, OliveGreen, Embedded, Metallic, Royale, RoyaleDark, Zune}
enum buttonStyle {Classic, Y2K}

# Window Themes
var LunaTheme : Theme = load("res://themes/eXP/eXP_Luna.tres")
var OliveTheme : Theme = load("res://themes/eXP/eXP_Olive.tres")
var EmbeddedTheme : Theme = load("res://themes/eXP/eXP_Embedded.tres")
var MetallicTheme : Theme = load("res://themes/eXP/eXP_Metallic.tres")
var RoyaleTheme : Theme = load("res://themes/eXP/eXP_Royale.tres")
var RoyaleDarkTheme : Theme = load("res://themes/eXP/eXP_RoyaleDark.tres")
var ZuneTheme : Theme = load("res://themes/eXP/eXP_Zune.tres")

# Task Themes
var LunaTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskLuna.tres")
var OliveTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskOlive.tres")
var EmbeddedTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskEmbedded.tres")
var MetallicTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskMetallic.tres")
var RoyaleTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskRoyale.tres")
var RoyaleDarkTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskRoyaleDark.tres")
var ZuneTask : Theme = load("res://sprites/UI/XP/taskbar/taskButtons/taskZune.tres")

# Icon Store
var icon_dict : Dictionary[String, Texture2D]

@export var firstBoot : bool
@export var skipWelcome : bool
@export var highFidelity : bool
@export var crtFilter : bool
@export var defaultTheme : TaskThemes
@export var defaultWindowTheme : Theme
@export var defaultButtonStyle : buttonStyle
@export var defaultWallpaper : Texture2D
@export var startTheme : MusicTrack
@export var shutdownTheme : MusicTrack

# Error Stats
enum errorType {critical, alert}
var errorCount : int
var trollMode : bool = false

# Player Stats
@export var playerName := "Adam"
@export var playerUser := "AdamZT395"
@export var playerPFP : Texture2D
var pfpIndex = 0

signal GetTrolled
signal CloseAppSignal(taskApp:String)
signal unlockWMP

@export var secret1 : bool = false
@export var secret2 : bool = false
@export var secret3 : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	firstBoot = true
	skipWelcome = false
	highFidelity = false
	crtFilter = false
	defaultTheme = TaskThemes.Luna
	defaultWindowTheme = LunaTheme
	defaultButtonStyle = buttonStyle.Classic
	startTheme = preload("res://MMSongs/XPStart.tres")
	shutdownTheme = preload("res://MMSongs/XPShutdown.tres")
	errorCount = 0
	
	# Resources
	# ProjectSettings.load_resource_pack("res://graphics.pck")
	# ProjectSettings.load_resource_pack("res://audio.pck")
	# get_tree().change_scene_to_file("res://scenes/main.tscn")

func activateTroll() -> void:
	GetTrolled.emit()

func activateWMP() -> void:
	unlockWMP.emit()

#func playSFX(sfx : AudioStream) -> void:
	#MusicManager.sfx_player.stream = sfx
	#MusicManager.sfx_player.play()

func closeApp(taskApp : String) -> void:
	CloseAppSignal.emit(taskApp)
