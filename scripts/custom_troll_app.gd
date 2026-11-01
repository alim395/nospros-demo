extends customWindow

var isMinimize : bool = false

@export var trollButton : TextureButton

var defaultVideo : VideoStreamTheora
@export var trollVideos : Array[VideoStreamTheora]

var currentIndex : int = 0
var randomArray : Array[int]

#signal trollButtonPress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	trollButton.disabled = true
	if trollVideos:
		defaultVideo = trollVideos[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

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
		if vIndex == 4:
			trollButton.disabled = false
		else:
			trollButton.disabled = true
		videoPlayer.stream = trollVideos[vIndex]
	else:
		videoPlayer.stream = vidSrc
	videoPlayer.play()
	_on_window_container_focus_entered()

func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	closeWindow()

func closeWindow() -> void:
	videoPlayer.stop()
	myWindow.visible = false
	if myTaskButton:
		myTaskButton.close_task()
	trollButton.disabled = true

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

func updateProgramIcon() -> void:
	setProgamIcon(globalParameters.icon_dict.get("TROLL"))

func _on_secret_2_button_pressed() -> void:
	if get_parent().get_parent():
		print("TROLLING NOW!")
		%IconManager._on_secret_2_button_pressed()
		get_parent().get_parent()._on_secret_2_button_pressed()
		#emit_signal("trollButtonPress")
	else:
		print("CANT TROLL RN MOFO")
