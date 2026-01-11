extends Control

@export var NEXT_SCENE_PATH: String = "res://scenes/game.tscn"

var progress = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(NEXT_SCENE_PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(NEXT_SCENE_PATH, progress)
	$ProgressBar.value = progress[0] * 100
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		$ProgressBar.value = 100
		await get_tree().create_timer(0.5).timeout
		MusicManager.is_looping_song = false
		MusicManager.stop_music.emit()
		var scene = ResourceLoader.load_threaded_get(NEXT_SCENE_PATH)
		get_tree().change_scene_to_packed(scene)
