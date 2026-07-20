extends customWindow

var isMinimize : bool = false
@export var myTaskButton : taskbarButton

@export var seekSlider : HSlider

@export var playButton : BaseButton
@export var pauseButton : BaseButton
@export var stopButton : BaseButton

@export var muteButton : BaseButton
@export var muteIcons : Array[Texture2D]
@export var volumeSlider : HSlider

var isSeeking : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if videoPlayer:
		if videoPlayer.stream:
			if not videoPlayer.stream.resource_name.is_empty():
				print(videoPlayer.stream.resource_name)
				setTitle(videoPlayer.stream.resource_name + " - Media Player")
			else:
				setTitle("Untitled - Media Player")
			#_on_play_button_button_up()
			seekSlider.value = 0
			seekSlider.max_value = videoPlayer.get_stream_length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if videoPlayer.is_playing():
		updateSeekSlider(videoPlayer.stream_position)

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

func openWindow() -> void:
	myWindow.visible = true
	_on_window_container_focus_entered()
	_on_play_button_button_up()
	
func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	closeWindow()

func closeWindow() -> void:
	_on_stop_button_button_up()
	myWindow.visible = false
	if get_parent():
		get_parent().get_node("%Taskbar").closeTask("WMP")
	queue_free()

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func updateSeekSlider(seconds := 0.0):
	if not isSeeking:
		seekSlider.set_value_no_signal(seconds)

func _on_seek_slider_drag_started() -> void:
	isSeeking = true
	videoPlayer.paused = true

func _on_seek_slider_drag_ended(value_changed: bool) -> void:
	isSeeking = false
	if value_changed:
		videoPlayer.stream_position = seekSlider.value
	_on_play_button_button_up()

func _on_play_button_button_up() -> void:
	videoPlayer.paused = false
	videoPlayer.play()
	playButton.disabled = true
	
	pauseButton.disabled = false
	stopButton.disabled = false

func _on_pause_button_button_up() -> void:
	videoPlayer.paused = true
	pauseButton.disabled = true
	
	playButton.disabled = false
	stopButton.disabled = false

func _on_stop_button_button_up() -> void:
	videoPlayer.stop()
	videoPlayer.play()
	videoPlayer.stream_position = seekSlider.step
	videoPlayer.paused = true
	updateSeekSlider()
	
	stopButton.disabled = true
	pauseButton.disabled = true
	playButton.disabled = false

func _on_mute_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		videoPlayer.volume_db = linear_to_db(0)
		muteButton.icon = muteIcons[1]
	else:
		videoPlayer.volume_db = linear_to_db(volumeSlider.value)
		muteButton.icon = muteIcons[0]

func _on_volume_slider_value_changed(value: float) -> void:
	if not muteButton.button_pressed:
		videoPlayer.volume_db = linear_to_db(value)

func _on_video_player_finished() -> void:
	_on_stop_button_button_up()

func updateProgramIcon() -> void:
	setProgamIcon(globalParameters.icon_dict.get("WMP"))
