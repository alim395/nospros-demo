extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var trollVideos : Array[VideoStreamTheora]
@export var videoPlayer : VideoStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func openWindow() -> void:
	myWindow.visible = true
	#MusicManager.stop_music.emit()
	if trollVideos:
		videoPlayer.stream = trollVideos[randi_range(0,trollVideos.size()-1)]
	videoPlayer.play()
	
	#MusicManager.play_song.emit(trollMusic, true, true, 0.5)

func _on_window_close_requested() -> void:
	myWindow.visible = false
	#MusicManager.stop_music.emit()
	videoPlayer.stop()
	%AppManager.taskBar.closeTask("Troll")
		

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func minimizeWindow() -> void:
	isMinimize = true
	myWindow.visible = not isMinimize
	if myTaskButton.button_pressed:
		isMinimize = false
		myWindow.visible = not isMinimize
		myWindow.grab_focus()
