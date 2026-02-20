extends Control

@export var myWindow : Window
@export var subWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var imageDisplay : TextureRect
@export var videoPlayer : VideoStreamPlayer

@export var mediaDict : Dictionary[String, Resource]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	imageDisplay.visible = false
	videoPlayer.visible = false

func openWindow() -> void:
	myWindow.visible = true

func displayImage(mediaKey : String) -> void:
	imageDisplay.visible = true
	videoPlayer.visible = false
	if videoPlayer.is_playing():
		videoPlayer.stop()
	if mediaDict.get(mediaKey):
		imageDisplay.texture = mediaDict.get(mediaKey)

func playVideo(mediaKey : String) -> void:
	imageDisplay.visible = false
	videoPlayer.visible = true
	if mediaDict.get(mediaKey):
		videoPlayer.stream = mediaDict.get(mediaKey)
		videoPlayer.play()

func _on_window_close_requested() -> void:
	myWindow.visible = false
	%AppManager.taskBar.closeTask("memes")

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func minimizeWindow() -> void:
	isMinimize = true
	myWindow.visible = not isMinimize
	#subWindow.visible = not isMinimize
	if myTaskButton.button_pressed:
		isMinimize = false
		myWindow.visible = not isMinimize
		#subWindow.visible = not isMinimize
		myWindow.grab_focus()

func changeTheme(t : Theme) -> void:
	myWindow.theme = t
	subWindow.theme = t

func _on_sub_window_close_requested() -> void:
	subWindow.visible = false
	videoPlayer.stop()

func _on_meme_image_button_pressed(imageKey: String) -> void:
	subWindow.visible = false
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	displayImage(imageKey)
	subWindow.visible = true

func _on_meme_video_button_pressed(videoKey: String) -> void:
	subWindow.visible = false
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	playVideo(videoKey)
	subWindow.visible = true
