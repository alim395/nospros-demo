extends Control

@export var activeInstance : Node
#@export var webInstance : Node

@export var clickSFX : AudioStream
@export var pictureApp : Control
@export var settingApp : Control
@export var trollApp : Control
@export var trollIcon : Control

# Apps
@onready var musicPlayerApp = preload("res://scenes/musicPlayer.tscn")
@onready var browserApp = preload("res://scenes/globeTrotter.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activeInstance = null
	#webInstance = null
	#closeCoreApps()
	globalParameters.GetTrolled.connect(_on_troll_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("DEBUG_OpenMusicApp") :
		openMusicApp()
	if Input.is_action_just_released("DEBUG_OpenSettingsApp") :
		openSettingsApp()
	if Input.is_action_just_released("DEBUG_ActivateTrollMode") :
		globalParameters.GetTrolled.emit()
	if globalParameters.trollMode:
		trollIcon.visible = true
		globalParameters.trollMode = false
	

func closeActiveInstance() -> void:
	activeInstance.queue_free()

#func closeWebInstance() -> void:
	#webInstance.queue_free()

func closeCoreApps() -> void:
	pictureApp._on_window_close_requested()
	settingApp._on_window_close_requested()
	trollApp._on_window_close_requested()

func playSFX(sfx : AudioStream) -> void:
	MusicManager.stop_music.emit()
	MusicManager.music_player_2.stream = sfx
	MusicManager.music_player_2.play()

func openMusicApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	activeInstance = musicPlayerApp.instantiate()
	add_child(activeInstance)

func openPhotoApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	pictureApp.openWindow()

func openSettingsApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	settingApp.openWindow()
	
func openWebApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	activeInstance = browserApp.instantiate()
	add_child(activeInstance)
	
func _on_music_button_pressed() -> void:
	openMusicApp()
	playSFX(clickSFX)

func _on_photo_button_pressed() -> void:
	openPhotoApp()
	playSFX(clickSFX)

func _on_settings_button_pressed() -> void:
	openSettingsApp()
	playSFX(clickSFX)

func openTrollApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	trollApp.openWindow()

func _on_troll_button_pressed() -> void:
	openTrollApp()

func _on_browser_button_pressed() -> void:
	openWebApp()
	playSFX(clickSFX)
