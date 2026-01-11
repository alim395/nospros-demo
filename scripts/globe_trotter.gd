extends Control

@export var gifVids : Array[VideoStream]
@export var webGIFPlayer : VideoStreamPlayer
@export var addressInput : LineEdit

var currentIndex := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if gifVids != null:
		randomPageGIF()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func randomPageGIF() -> void:
	webGIFPlayer.stream = null
	var randomIndex = randi_range(0, (gifVids.size() - 1))
	if(randomIndex == currentIndex):
		randomPageGIF()
	else:
		currentIndex = randomIndex
		webGIFPlayer.stream = gifVids[randomIndex]
		webGIFPlayer.play()

func _on_window_close_requested() -> void:
	#MusicManager.stop_music.emit()
	queue_free()


func _on_home_pressed() -> void:
	addressInput.text = "https://www.example.com/index.php"
	randomPageGIF()
