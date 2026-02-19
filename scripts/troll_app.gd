extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var trollVideos : Array[VideoStreamTheora]
@export var videoPlayer : VideoStreamPlayer

@export var trollButton : TextureButton
var defaultVideo : VideoStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trollButton.disabled = true
	if trollVideos:
		defaultVideo = trollVideos[0]

func openWindow(isRandom : bool = true, vidSrc : VideoStream = defaultVideo) -> void:
	myWindow.visible = true
	#MusicManager.stop_music.emit()
	if isRandom:
		var vIndex = randi_range(0,trollVideos.size()-1)
		if vIndex == 2:
			trollButton.disabled = false
		else:
			trollButton.disabled = true
		videoPlayer.stream = trollVideos[vIndex]
	else:
		videoPlayer.stream = vidSrc
	videoPlayer.play()

func _on_window_close_requested() -> void:
	myWindow.visible = false
	#MusicManager.stop_music.emit()
	videoPlayer.stop()
	%AppManager.taskBar.closeTask("Troll")
	trollButton.disabled = true

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
