extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var trollVideos : Array[VideoStreamTheora]
@export var videoPlayer : VideoStreamPlayer

@export var trollButton : TextureButton
var defaultVideo : VideoStream
var currentIndex : int = 0
var randomArray : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trollButton.disabled = true
	if trollVideos:
		defaultVideo = trollVideos[0]

func openWindow(isRandom : bool = true, vidSrc : VideoStream = defaultVideo) -> void:
	myWindow.visible = true
	#MusicManager.stop_music.emit()
	if isRandom:
		if randomArray.is_empty() || currentIndex == randomArray.size():
			currentIndex = 0
			randomArray.assign(range(trollVideos.size()))
			randomArray.shuffle()
			print(randomArray)
		var vIndex = randomArray[currentIndex]
		currentIndex += 1
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

func _on_theme_changed() -> void:
	myWindow.theme = theme
