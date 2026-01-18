extends Control

@export var activeInstance : Node
var activeTaskName : String
#@export var webInstance : Node

#@export var clickSFX : AudioStream
@export var pictureApp : Control
@export var settingApp : Control
@export var trollApp : Control
@export var trollIcon : Control
@export var taskBar : Taskbar

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
	taskBar.closeTask(activeTaskName)
	activeInstance.queue_free()

#func closeWebInstance() -> void:
	#webInstance.queue_free()

func closeCoreApps() -> void:
	pictureApp._on_window_close_requested()
	taskBar.closeTask("Picture")
	settingApp._on_window_close_requested()
	taskBar.closeTask("Setting")
	trollApp._on_window_close_requested()
	taskBar.closeTask("Troll")

func openMusicApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	activeInstance = musicPlayerApp.instantiate()
	add_child(activeInstance)
	activeTaskName = "Music"
	var tB = taskBar.openTask(activeTaskName)
	activeInstance.setTaskButton(tB)

func openPhotoApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	pictureApp.openWindow()
	activeTaskName = "Picture"
	var tB = taskBar.openTask(activeTaskName)
	pictureApp.setTaskButton(tB)

func openSettingsApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	settingApp.openWindow()
	activeTaskName = "Setting"
	var tB = taskBar.openTask(activeTaskName)
	settingApp.setTaskButton(tB)
	
func openWebApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	activeInstance = browserApp.instantiate()
	add_child(activeInstance)
	activeTaskName = "Browser"
	var tB = taskBar.openTask(activeTaskName)
	activeInstance.setTaskButton(tB)
	
func _on_music_button_pressed() -> void:
	openMusicApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_photo_button_pressed() -> void:
	openPhotoApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_settings_button_pressed() -> void:
	openSettingsApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func openTrollApp() -> void:
	if activeInstance != null:
		closeActiveInstance()
	closeCoreApps()
	trollApp.openWindow()
	activeTaskName = "Troll"
	var tB = taskBar.openTask(activeTaskName)
	trollApp.setTaskButton(tB)

func _on_troll_button_pressed() -> void:
	openTrollApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_browser_button_pressed() -> void:
	openWebApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func closeAllTasks() -> void:
	closeActiveInstance()
	closeCoreApps()
