extends Control

@export var activeInstance : Node
var activeTaskName : String

# Multitask Instances
var webInstance : Node
var musicInstance : Node
var isTrolling : bool = false

var taskCount : int = 0

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
	webInstance = null
	musicInstance = null
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
	if activeInstance != null:
		activeInstance.queue_free()
		activeInstance = null
	updateTaskCount()

func closeWebInstance() -> void:
	taskBar.closeTask("Browser")
	if webInstance != null:
		webInstance.queue_free()
		webInstance = null
	updateTaskCount()

func closeMusicInstance() -> void:
	taskBar.closeTask("Music")
	if musicInstance != null:
		musicInstance.queue_free()
		musicInstance = null
	updateTaskCount()

func closeCoreApps() -> void:
	pictureApp._on_window_close_requested()
	taskBar.closeTask("Picture")
	settingApp._on_window_close_requested()
	taskBar.closeTask("Setting")
	closeTroll()

func openMusicApp() -> void:
	#if activeInstance != null:
		#closeActiveInstance()
	##closeCoreApps()
	#activeInstance = musicPlayerApp.instantiate()
	#add_child(activeInstance)
	#activeTaskName = "Music"
	#var tB = taskBar.openTask(activeTaskName)
	#activeInstance.setTaskButton(tB)
	
	if musicInstance == null:
		closeTroll()
		musicInstance = musicPlayerApp.instantiate()
		add_child(musicInstance)
		if taskCount > 0:
			musicInstance.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
		var tB = taskBar.openTask("Music")
		musicInstance.setTaskButton(tB)
		updateTaskCount()

func openPhotoApp() -> void:
	#if activeInstance != null:
		#closeActiveInstance()
	closeCoreApps()
	pictureApp.openWindow()
	if taskCount > 0:
			pictureApp.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
	activeTaskName = "Picture"
	var tB = taskBar.openTask(activeTaskName)
	pictureApp.setTaskButton(tB)

func openSettingsApp() -> void:
	#if activeInstance != null:
		#closeActiveInstance()
	closeCoreApps()
	settingApp.openWindow()
	if taskCount > 0:
			settingApp.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
	activeTaskName = "Setting"
	var tB = taskBar.openTask(activeTaskName)
	settingApp.setTaskButton(tB)
	
func openWebApp() -> void:
	#if activeInstance != null:
		#closeActiveInstance()
	##closeCoreApps()
	#activeInstance = browserApp.instantiate()
	#add_child(activeInstance)
	#activeTaskName = "Browser"
	#var tB = taskBar.openTask(activeTaskName)
	#activeInstance.setTaskButton(tB)
	
	if webInstance == null:
		closeTroll()
		webInstance = browserApp.instantiate()
		add_child(webInstance)
		if taskCount > 0:
			webInstance.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
		var tB = taskBar.openTask("Browser")
		webInstance.setTaskButton(tB)
		updateTaskCount()
	
func _on_music_button_pressed() -> void:
	closeTroll()
	openMusicApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_photo_button_pressed() -> void:
	openPhotoApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_settings_button_pressed() -> void:
	openSettingsApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func openTrollApp() -> void:
	closeAllTasks()
	# Added Delay to allow music to be played
	await get_tree().create_timer(0.1).timeout
	trollApp.openWindow()
	isTrolling = true
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
	closeWebInstance()
	closeMusicInstance()
	closeCoreApps()

func closeTroll() -> void:
	if isTrolling:
		trollApp._on_window_close_requested()
		taskBar.closeTask("Troll")
		isTrolling = false

func updateTaskCount() -> void:
	taskCount = 0
	if activeInstance != null:
		taskCount +=1
	if webInstance != null:
		taskCount +=1
	if musicInstance != null:
		taskCount +=1
