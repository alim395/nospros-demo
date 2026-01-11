extends Node2D

@export var logOnSound : AudioStream
@export var buttonManager : Control
@export var shutdownButton : BaseButton

@export var startButton : Button
@export var startLabel : Label

@export var crtNode : CRT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init Start Butoon and Labels
	startButton.text = globalParameters.playerName + "\n \n"
	if globalParameters.playerPFP != null:
		startButton.icon = globalParameters.playerPFP
	
	if OS.get_name() == "Web":
		shutdownButton.disabled = true
	if shutdownButton.disabled == true:
		shutdownButton.tooltip_text = "Not available in web build."
	#print(globalParameters.defaultTheme)
	crtNode.visible = globalParameters.crtFilter

func _on_start_pressed() -> void:
	buttonManager.visible = false
	# MusicManager.stop_music.emit()
	MusicManager.music_player_2.stream = logOnSound
	MusicManager.music_player_2.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	print(globalParameters.defaultTheme)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
