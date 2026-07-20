extends customWindow

@export var subWindowNode : customWindow
var subWindow : Control
@export var myTaskButton : taskbarButton
@export var subTaskButton : taskbarButton = null
var isMinimize : bool = false
var isSubMinimize : bool = false

@export var mediaDict : Dictionary[String, Resource]

@export var folderRows : HFlowContainer
var mBScene: PackedScene = preload("res://scenes/buttons/photoButton.tscn")
var photoMemesPath : String = "res://sprites/memes/"
var videoMemesPath : String = "res://video/memes/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	setProgamIcon(globalParameters.icon_dict.get("memes"))
	subWindow = $CustomSubWindow/WindowContainer
	subWindowNode.closeButton.pressed.connect(closeSubWindow)
	generateMemeButtons()
	subWindowNode.imageDisplay.visible = false
	subWindowNode.videoPlayer.visible = false

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func setSubTaskButton(tB : taskbarButton) -> void:
	subTaskButton = tB
	subTaskButton.pressed.connect(minimizeSubWindow)

func _on_minimize_button_button_up() -> void:
	super._on_minimize_button_button_up()
	if myTaskButton:
		myTaskButton.button_pressed = false

func minimizeWindow() -> void:
	if myTaskButton:
		isMinimize = true
		myWindow.visible = not isMinimize
		if myTaskButton.button_pressed:
			isMinimize = false
			myWindow.visible = not isMinimize
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

func openWindow() -> void:
	myWindow.visible = true
	_on_window_container_focus_entered()

func _on_window_container_focus_entered() -> void:
	super._on_window_container_focus_entered()
	move_child(myWindow, -1)

func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	closeWindow()

func closeWindow() -> void:
	myWindow.visible = false
	if get_parent():
		%AppManager.taskBar.closeTask("Memes")
		#_on_sub_window_close_requested()

func closeSubWindow() -> void:
	subWindow.visible = false
	if subWindowNode.videoPlayer:
		subWindowNode.videoPlayer.stop()
	if get_parent():
		%AppManager.taskBar.closeTask("memePlayer")

func displayImage(mediaKey : String) -> void:
	subWindowNode.visible = true
	subWindowNode.imageDisplay.visible = true
	subWindowNode.videoPlayer.visible = false
	if subWindowNode.videoPlayer.is_playing():
		subWindowNode.videoPlayer.stop()
	if mediaDict.get(mediaKey):
		subWindowNode.imageDisplay.texture = mediaDict.get(mediaKey)
	subWindowNode._on_window_container_focus_entered()

func playVideo(mediaKey : String) -> void:
	subWindowNode.visible = true
	subWindowNode.imageDisplay.visible = false
	subWindowNode.videoPlayer.visible = true
	if mediaDict.get(mediaKey):
		subWindowNode.videoPlayer.stream = mediaDict.get(mediaKey)
		subWindowNode.videoPlayer.play()
	subWindowNode._on_window_container_focus_entered()

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

func _on_meme_image_button_pressed(imageKey: String) -> void:
	subWindow.visible = false
	subWindowNode.videoPlayer.stop()
	%AppManager.taskBar.closeTask("memePlayer")
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	displayImage(imageKey)
	subWindowNode.setTitle(imageKey)
	subWindow.visible = true
	# Sub Task Button
	var tB = %Taskbar.openTask("memePlayer")
	setSubTaskButton(tB)

func _on_meme_video_button_pressed(videoKey: String) -> void:
	subWindow.visible = false
	subWindowNode.videoPlayer.stop()
	%AppManager.taskBar.closeTask("memePlayer")
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	playVideo(videoKey)
	subWindowNode.setTitle(videoKey)
	subWindow.visible = true
	# Sub Task Button
	var tB = %Taskbar.openTask("memePlayer")
	setSubTaskButton(tB)

func updateTheme() -> void:
	super.updateTheme()
	subWindowNode.theme = theme

func updateProgramIcon() -> void:
	setProgamIcon(globalParameters.icon_dict.get("memes"))
