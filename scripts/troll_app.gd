extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var trollMusic : MusicTrack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func openWindow() -> void:
	myWindow.visible = true
	MusicManager.stop_music.emit()
	MusicManager.play_song.emit(trollMusic, true, true, 0.5)

func _on_window_close_requested() -> void:
	myWindow.visible = false
	MusicManager.stop_music.emit()
	%AppManager.taskBar.closeTask("Troll")
		

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func minimizeWindow() -> void:
	isMinimize = not isMinimize
	myWindow.visible = not isMinimize
