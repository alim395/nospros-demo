extends Node2D

@export var startSong : MusicTrack
@export var welcomeScreen : Control
@export var welcomeAnimation : AnimationPlayer

@export var ScreenFilter : Node2D
@export var softBlur : ColorRect
@export var crtNode : CRT
@export var Task_Bar : Control
@export var iconManager : Control
@export var appManager : Control

@export var loginDelay : Timer

@export var logScreen : Control
@export var logAnimation : AnimationPlayer
#@export var logOffSound : AudioStream
@export var logOffSong : MusicTrack

@export var shutdownSong : MusicTrack
@export var shutdownScreen : Control
@export var shutdownAnimation : AnimationPlayer

# Error Window
@onready var errorWindow = preload("res://scenes/errorWindow.tscn")
var currentError : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ScreenFilter.visible = true;
	softBlur.visible = not globalParameters.highFidelity
	crtNode.visible = globalParameters.crtFilter
	logScreen.visible = false;
	shutdownScreen.visible = false;
	if(!globalParameters.skipWelcome):
		loginDelay.autostart = true
		welcomeScreen.visible = true;
		Task_Bar.visible = false;
		iconManager.visible = false;
	else:
		loginDelay.queue_free()
		welcomeScreen.visible = false;
		Task_Bar.visible = true;
		iconManager.visible = true;
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_login_delay_timeout() -> void:
	MusicManager.play_song.emit(startSong, false, false, 0)
	welcomeAnimation.play("fade_out")
	
func _on_welcome_animation_animation_finished(_anim_name: StringName) -> void:
	Task_Bar.visible = true;
	await get_tree().create_timer(0.5).timeout
	iconManager.visible = true;
	globalParameters.skipWelcome = true
	welcomeScreen.queue_free()

func _on_power_options_pressed() -> void:
	print("POWER OPTIONS SELECTED")
	if appManager.activeInstance != null:
		appManager.activeInstance.queue_free()
	appManager.closeCoreApps()
	logScreen.visible = true;
	logAnimation.play("becomeGray")

func _on_shutdown_button_pressed() -> void:
	if OS.get_name() != "Web" :
		appManager.queue_free()
		shutdownAnimation.play("shutdown")
	else:
		_on_exit_back_pressed()
		currentError = errorWindow.instantiate()
		add_child(currentError)
		if(globalParameters.errorCount < 10):
			currentError.setMessage("This feature is unavailable in the Web Build.")
	
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
	%Taskbar._on_power_options_pressed()
	if(currentError == null) :
		currentError = errorWindow.instantiate()
		add_child(currentError)
	if(globalParameters.errorCount < 10):
		currentError.setMessage("This feature is not yet available.")
