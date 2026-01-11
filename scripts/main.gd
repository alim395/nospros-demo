extends Node2D

@export var backgroundSong : MusicTrack
@export var shutdownButton : BaseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_song.emit(backgroundSong, true, true, 0.5)
	globalParameters.skipWelcome = false
	if OS.get_name() == "Web":
		shutdownButton.disabled = true
	if shutdownButton.disabled == true:
		shutdownButton.tooltip_text = "Not available in web build."

func _on_start_pressed() -> void:
	# MusicManager.stop_music.emit()
	get_tree().change_scene_to_file("res://scenes/loadStartXP.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
