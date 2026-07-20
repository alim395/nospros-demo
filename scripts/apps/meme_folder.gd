extends Control

@export var myWindow : Window
@export var subWindow : Window
@export var myTaskButton : taskbarButton
@export var subTaskButton : taskbarButton = null
var isMinimize : bool = false
var isSubMinimize : bool = false

@export var imageDisplay : TextureRect
@export var videoPlayer : VideoStreamPlayer

@export var mediaDict : Dictionary[String, Resource]

@export var folderRows : HFlowContainer
var mBScene: PackedScene = preload("res://scenes/buttons/photoButton.tscn")
var photoMemesPath : String = "res://sprites/memes/"
var videoMemesPath : String = "res://video/memes/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generateMemeButtons()
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
	_on_sub_window_close_requested()

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func setSubTaskButton(tB : taskbarButton) -> void:
	subTaskButton = tB
	subTaskButton.pressed.connect(minimizeSubWindow)

func minimizeWindow() -> void:
	isMinimize = true
	myWindow.visible = not isMinimize
	#subWindow.visible = not isMinimize
	if myTaskButton.button_pressed:
		isMinimize = false
		myWindow.visible = not isMinimize
		#subWindow.visible = not isMinimize
		myWindow.grab_focus()

func minimizeSubWindow() -> void:
	isSubMinimize = true
	subWindow.visible = not isSubMinimize
	#subWindow.visible = not isMinimize
	if subTaskButton.button_pressed:
		isSubMinimize = false
		subWindow.visible = not isSubMinimize
		#subWindow.visible = not isMinimize
		subWindow.grab_focus()

func changeTheme(t : Theme) -> void:
	myWindow.theme = t
	subWindow.theme = t

func _on_sub_window_close_requested() -> void:
	subWindow.visible = false
	videoPlayer.stop()
	%AppManager.taskBar.closeTask("memePlayer")

func _on_meme_image_button_pressed(imageKey: String) -> void:
	subWindow.visible = false
	videoPlayer.stop()
	%AppManager.taskBar.closeTask("memePlayer")
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	displayImage(imageKey)
	subWindow.title = imageKey
	subWindow.visible = true
	# Sub Task Button
	var tB = %Taskbar.openTask("memePlayer")
	setSubTaskButton(tB)

func _on_meme_video_button_pressed(videoKey: String) -> void:
	subWindow.visible = false
	videoPlayer.stop()
	%AppManager.taskBar.closeTask("memePlayer")
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	playVideo(videoKey)
	subWindow.title = videoKey
	subWindow.visible = true
	# Sub Task Button
	var tB = %Taskbar.openTask("memePlayer")
	setSubTaskButton(tB)

func generateMemeButtons() -> void:
	# Load Images
	if ResourceLoader.list_directory(photoMemesPath):
		var photoMemes : PackedStringArray = ResourceLoader.list_directory(photoMemesPath)
		for p in photoMemes:
			# Ignore Directories
			if p.contains("/"):
				continue
			var memeName : String = p.split(".")[0]
			var memePhoto : Texture2D = ResourceLoader.load(photoMemesPath + p) as Texture2D
			# Add to Media Dictionary
			mediaDict[memeName] = memePhoto
			# Add button
			var mB = mBScene.instantiate()
			mB.call("setPhoto", memePhoto)
			mB.call("setLabel", memeName)
			var mBButton : TextureButton = mB.pButton
			mBButton.connect("pressed", _on_meme_image_button_pressed.bind(memeName))
			mBButton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			folderRows.add_child(mB)
	# Load Videos
	if ResourceLoader.list_directory(videoMemesPath):
		var videoMemes : PackedStringArray = ResourceLoader.list_directory(videoMemesPath)
		var videoThumbs : PackedStringArray = ResourceLoader.list_directory(videoMemesPath + "thumb/")
		# Construct Thumbnail Dict
		var vidThumbDict : Dictionary[String, Texture2D] = {}
		for t in videoThumbs:
			# Ignore Directories
			if t.contains("/"):
				continue
			var thumbName : String = t.split(".")[0]
			var thumbPhoto : Texture2D = ResourceLoader.load(videoMemesPath + "thumb/" + t) as Texture2D
			# Add to thumb Dictionary
			vidThumbDict[thumbName] = thumbPhoto
		# Make Video Buttons
		for v in videoMemes:
			# Ignore Directories
			if v.contains("/"):
				continue
			var memeName : String = v.split(".")[0]
			# Get Thumbnail
			var memePhoto : Texture2D = vidThumbDict[memeName]
			# Get Video
			var memeVideo : VideoStreamTheora = ResourceLoader.load(videoMemesPath + v) as VideoStreamTheora
			# Add to Media Dictionary
			mediaDict[memeName] = memeVideo
			# Add button
			var mB = mBScene.instantiate()
			mB.call("setPhoto", memePhoto)
			mB.call("setLabel", memeName)
			var mBButton : TextureButton = mB.pButton
			mBButton.connect("pressed", _on_meme_video_button_pressed.bind(memeName))
			mBButton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			folderRows.add_child(mB)
