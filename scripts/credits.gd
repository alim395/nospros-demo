extends Control

@export var creditsSong : MusicTrack
@export var goBackSong : MusicTrack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_song.emit(creditsSong, false, false,0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_end_label_meta_clicked(_meta: Variant) -> void:
	MusicManager.stop_music.emit()
	MusicManager.play_song.emit(goBackSong, false, false, 0.5)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
