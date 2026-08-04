extends Node2D

var startSong : MusicTrack
@export var welcomeScreen : Control
@export var welcomeName : Label
@export var welcomeAnimation : AnimationPlayer

@export var ScreenFilter : Node2D
@export var softBlur : ColorRect
@export var crtNode : CRT
@export var Task_Bar : Control
@export var iconManager : Control
@export var appManager : Control
@export var taskBar : Taskbar

@export var loginDelay : Timer

@export var logScreen : Control
@export var logAnimation : AnimationPlayer
#@export var logOffSound : AudioStream
@export var logOffSong : MusicTrack

var shutdownSong : MusicTrack
@export var shutdownScreen : Control
@export var shutdownAnimation : AnimationPlayer

# Error Window
@export var dialogueWindowNode : Control
@onready var errorWindow = preload("res://scenes/dialogs/errorWindow.tscn")
@onready var ynWindow = preload("res://scenes/dialogs/YNWindow.tscn")
#var currentError : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Signal
	globalParameters.CloseAppSignal.connect(closeApp)
	globalParameters.unlockWMP.connect(_on_secret_3_button_pressed)
	startSong = globalParameters.startTheme
	shutdownSong = globalParameters.shutdownTheme
	welcomeName.text = globalParameters.playerName
	ScreenFilter.visible = true;
	softBlur.visible = not globalParameters.highFidelity
	crtNode.visible = globalParameters.crtFilter
	logScreen.visible = false;
	shutdownScreen.visible = false;
	if(!globalParameters.skipWelcome):
		loginDelay.autostart = true
		welcomeScreen.visible = true;
		Task_Bar.visible = false;
		Task_Bar.visibility_changed.emit()
		iconManager.visible = false;
	else:
		loginDelay.queue_free()
		welcomeScreen.visible = false;
		Task_Bar.visible = true;
		Task_Bar.visibility_changed.emit()
		iconManager.visible = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_login_delay_timeout() -> void:
	MusicManager.play_song.emit(startSong, false, false, 0)
	welcomeAnimation.play("fade_out")
	
func _on_welcome_animation_animation_finished(_anim_name: StringName) -> void:
	#var fps : float = Engine.get_frames_per_second()
	#if fps < 60.0:
		#print("LOW FPS DETECTED")
		#globalParameters.highFidelity = true
		#softBlur.visible = not globalParameters.highFidelity
	Task_Bar.visible = true;
	await get_tree().create_timer(0.5).timeout
	iconManager.visible = true;
	globalParameters.skipWelcome = true
	welcomeScreen.queue_free()

func _on_power_options_pressed() -> void:
	print("POWER OPTIONS SELECTED")
	appManager.closeAllTasks()
	#if currentError != null:
		#currentError.queue_free()
	logScreen.visible = true;
	logAnimation.play("becomeGray")

func _on_shutdown_button_pressed() -> void:
	if OS.get_name() != "Web" :
		appManager.queue_free()
		shutdownAnimation.play("shutdown")
	else:
		_on_exit_back_pressed()
		spawnError("This feature is unavailable in the Web Build.")
	
func _on_shutdown_animation_animation_finished(_anim_name: StringName) -> void:
	MusicManager.play_song.emit(shutdownSong, false, false, 0)
	await get_tree().create_timer(6.0).timeout
	get_tree().quit()

func _on_exit_back_pressed() -> void:
	logScreen.visible = false;
	logAnimation.play("RESET")

func _on_log_off_pressed() -> void:
	logScreen.visible = false;
	logAnimation.play("RESET")
	get_tree().change_scene_to_file("res://scenes/mainLog.tscn")
	MusicManager.stop_music.emit()
	MusicManager.play_song.emit(logOffSong, false, false, 0)

func _on_untitled_button_pressed() -> void:
	taskBar._on_power_options_pressed()
	spawnError()

func closeApp(taskApp : String) -> void:
	appManager.taskBar.closeTask(taskApp)

func spawnError(msg : String = "This feature is not available yet.", eType : int = globalParameters.errorType.critical) -> void:
	var d = errorWindow.instantiate()
	d.setErrorType(eType)
	d.setErrorMessage(msg)
	dialogueWindowNode.add_child(d)
	if dialogueWindowNode.get_children():
		if dialogueWindowNode.get_child_count() > 1:
			d.myWindow.position += Vector2i(randi_range(10,40), randi_range(10,40))

func spawnYN(msg:String = "YES or No?", title:String = "Untitled", isCool : bool = false):
	var d = ynWindow.instantiate()
	d.setMessage(msg)
	d.setTitle(title)
	if isCool:
		d.toggleCoolMessage()
	dialogueWindowNode.add_child(d)
	if dialogueWindowNode.get_children():
		if dialogueWindowNode.get_child_count() > 1:
			d.myWindow.position += Vector2i(randi_range(10,40), randi_range(10,40))
	return d

func _on_secret_2_button_pressed() -> void:
	if globalParameters.secret2 == false:
		globalParameters.secret2 = true
		spawnError("SECRET 2 UNLOCKED!\n Memes Folder Available", globalParameters.errorType.alert)

func _on_secret_3_button_pressed() -> void:
	if globalParameters.secret3 == false:
		globalParameters.secret3 = true
		spawnError("SECRET 3 UNLOCKED!\n Media Player Available", globalParameters.errorType.alert)
		await get_tree().create_timer(10.0).timeout
		var yn = spawnYN("ALL SECRETS UNLOCKED\nWould you like to see the credits?","Game Complete", true)
		yn.yesPress.connect(beginCredits)

func beginCredits() -> void:
	globalParameters.creditsBool = true
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
