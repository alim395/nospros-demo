extends Node2D

#@export var logOnSound : AudioStream
@export var logOnSong : MusicTrack
@export var buttonManager : Control
@export var shutdownButton : BaseButton

@export var startButton : Button
@export var startLabel : Label

@export var softBlur : Node2D
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
	softBlur.visible = not globalParameters.highFidelity

func _on_start_pressed() -> void:
	buttonManager.visible = false
	# MusicManager.stop_music.emit()
	MusicManager.play_song.emit(logOnSong, false, false, 0.5)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	print(globalParameters.defaultTheme)


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
