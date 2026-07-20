extends Control

@export var activeInstance : Node
var activeTaskName : String

# Multitask Instances
var webInstance : Node
var musicInstance : Node
var wmpInstance : Node
var tfInstance : Node
#var photoInstance : Node
var isTrolling : bool = false

var taskCount : int = 0

#@export var clickSFX : AudioStream
#@export var pictureApp : Control
@export var settingApp : Control
@export var pcApp : Control
@export var trollApp : Control
#@export var memeFolder : Control
@export var trollIcon : Control
@export var taskBar : Taskbar

#@export_multiline var changelogText : String

# Apps
@onready var musicPlayerApp = preload("res://scenes/customApps/customMusicPlayer.tscn")
@onready var browserApp = preload("res://scenes/apps/globeTrotter.tscn")
@onready var notepadApp = preload("res://scenes/customApps/customNotepad.tscn")
@onready var wmpApp = preload("res://scenes/customApps/customMediaPlayer.tscn")

# custom Apps
@export var customPictureApp : Control
@export var customMemeFolder : Control
#@export var customMediaPlayer : Control

# Others
@export var dWins : Control
@export var NotepadWins : Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activeInstance = null
	webInstance = null
	musicInstance = null
	wmpInstance = null
	#closeCoreApps()
	globalParameters.GetTrolled.connect(_on_troll_button_pressed)
	theme = globalParameters.defaultWindowTheme
	visible = true
	for app in get_children():
		app.visible = false
	dWins.visible = true
	NotepadWins.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_released("DEBUG_OpenMusicApp") :
		openCustomMusicApp()
	if Input.is_action_just_released("DEBUG_OpenSettingsApp") :
		openSettingsApp()
	if Input.is_action_just_released("DEBUG_ActivateTrollMode") :
		globalParameters.GetTrolled.emit()
	if Input.is_action_just_released("DEBUG_OpenMediaApp") :
		openCustomMediaPlayer()
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
	if musicInstance != null:
		musicInstance.closeWindow()
		musicInstance = null
	updateTaskCount()

func closeCoreApps() -> void:
	#pictureApp._on_window_close_requested()
	#taskBar.closeTask("Picture")
	settingApp._on_window_close_requested()
	taskBar.closeTask("Setting")
	pcApp._on_window_close_requested()
	taskBar.closeTask("Computer")

#func openMusicApp() -> void:
	#if musicInstance == null:
		#musicInstance = musicPlayerApp.instantiate()
		#add_child(musicInstance)
		#if taskCount > 0:
			#musicInstance.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
		#var tB = taskBar.openTask("Music")
		#musicInstance.setTaskButton(tB)
		#updateTaskCount()
	#else:
		#print("MUSIC ALREADY OPEN!")
		#musicInstance.myTaskButton.set_pressed_no_signal(true)
		#musicInstance.minimizeWindow()
		#
	#if globalParameters.secret1 and globalParameters.secret2 and not globalParameters.secret3:
			#musicInstance.activateS3()

func openCustomMusicApp() -> void:
	if musicInstance == null:
		musicInstance = musicPlayerApp.instantiate()
		add_child(musicInstance)
		musicInstance.openWindow()
		if taskCount > 0:
			musicInstance.myWindow.position += Vector2(randi_range(10,20), randi_range(10,20))
		var tB = taskBar.openTask("Music")
		musicInstance.setTaskButton(tB)
		updateTaskCount()
	else:
		print("MUSIC ALREADY OPEN!")
		musicInstance.myTaskButton.set_pressed_no_signal(true)
		musicInstance.minimizeWindow()
		
	if globalParameters.secret1 and globalParameters.secret2 and not globalParameters.secret3:
		musicInstance.activateS3()

#func openPhotoApp() -> void:
	#closeCoreApps()
	#pictureApp.openWindow()
	#if taskCount > 0:
			#pictureApp.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
	#activeTaskName = "Picture"
	#var tB = taskBar.openTask(activeTaskName)
	#pictureApp.setTaskButton(tB)

func openCustomPictureApp() -> void:
	customPictureApp.closeWindow()
	customPictureApp.openWindow()
	updateAppIcons()
	customPictureApp.visible = true
	#if taskCount > 0:
			#customPictureApp.myWindow.position += Vector2(randi_range(10,20), randi_range(10,20))
	activeTaskName = "Picture"
	var tB = taskBar.openTask(activeTaskName)
	customPictureApp.setTaskButton(tB)
	updateTaskCount()

func closeCustomPictureApp() -> void:
	customPictureApp.closeWindow()
	taskBar.closeTask("Picture")
	updateTaskCount()

func openSettingsApp() -> void:
	closeCoreApps()
	settingApp.openWindow()
	if taskCount > 0:
			settingApp.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
	activeTaskName = "Setting"
	var tB = taskBar.openTask(activeTaskName)
	settingApp.setTaskButton(tB)
	
func openWebApp() -> void:
	if webInstance == null:
		webInstance = browserApp.instantiate()
		add_child(webInstance)
		if taskCount > 0:
			webInstance.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
		var tB = taskBar.openTask("Browser")
		webInstance.setTaskButton(tB)
		updateTaskCount()
	else:
		print("BROWSER ALREADY OPEN!")
		webInstance.myTaskButton.set_pressed_no_signal(true)
		webInstance.minimizeWindow()
	
func _on_music_button_pressed() -> void:
	openCustomMusicApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_photo_button_pressed() -> void:
	#openPhotoApp()
	openCustomPictureApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func _on_settings_button_pressed() -> void:
	openSettingsApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func openTrollApp() -> void:
	trollApp._on_window_close_requested()
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
	closeTextInstance()
	closeCoreApps()
	closeTroll()
	closeCustomPictureApp()
	closeCustomMemeFolder()
	closeCustomMediaPlayer()
	dWins.closeAllDialogues()
	NotepadWins.closeAllNotepads()

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
	print(taskCount)

func updateTheme() -> void:
	theme = globalParameters.defaultWindowTheme
	if webInstance != null:
		webInstance.theme = globalParameters.defaultWindowTheme
	if musicInstance != null:
		musicInstance.theme = globalParameters.defaultWindowTheme
	if tfInstance != null:
		tfInstance.theme = globalParameters.defaultWindowTheme
	if wmpInstance != null:
		wmpInstance.theme = globalParameters.defaultWindowTheme
	if activeInstance != null:
		activeInstance.theme = globalParameters.defaultWindowTheme
	settingApp.theme = globalParameters.defaultWindowTheme
	trollApp.theme = globalParameters.defaultWindowTheme
	pcApp.theme = globalParameters.defaultWindowTheme
	customPictureApp.theme = globalParameters.defaultWindowTheme
	customMemeFolder.theme = globalParameters.defaultWindowTheme
	
	# Dialog Windows
	if dWins.get_children():
		for d in dWins.get_children():
			d.myWindow.theme = globalParameters.defaultWindowTheme
	
	# Notepad Windows
	if NotepadWins.get_children():
		for n in NotepadWins.get_children():
			n.theme = globalParameters.defaultWindowTheme


func _on_meme_button_pressed() -> void:
	#openMemeFolder()
	openCustomMemeFolder()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

#func openMemeFolder() -> void:
	#memeFolder._on_window_close_requested()
	#memeFolder.openWindow()
	#activeTaskName = "memes"
	#var tB = taskBar.openTask(activeTaskName)
	#memeFolder.setTaskButton(tB)

func openCustomMemeFolder() -> void:
	customMemeFolder.closeWindow()
	customMemeFolder.openWindow()
	updateAppIcons()
	customMemeFolder.visible = true
	if taskCount > 0:
			customMemeFolder.myWindow.position += Vector2(randi_range(10,20), randi_range(10,20))
	activeTaskName = "Memes"
	var tB = taskBar.openTask(activeTaskName)
	customMemeFolder.setTaskButton(tB)

func closeCustomMemeFolder() -> void:
	customMemeFolder.closeWindow()
	taskBar.closeTask("Memes")
	updateTaskCount()

func _on_textFile_button_pressed() -> void:
	openTextFile()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func openTextFile() -> void:
	if not NotepadWins.getActiveNotepad("README"):
		NotepadWins.openNotepad("README")
	else:
		NotepadWins.unMinNotepad("README")
		taskBar.focusTask("README - Notepad")

func closeTextInstance() -> void:
	taskBar.closeTask("README - Notepad")
	if tfInstance != null:
		tfInstance.queue_free()
		tfInstance = null
	updateTaskCount()

func openPCApp() -> void:
	closeCoreApps()
	pcApp.openWindow()
	if taskCount > 0:
			pcApp.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
	activeTaskName = "Computer"
	var tB = taskBar.openTask(activeTaskName)
	pcApp.setTaskButton(tB)

func _on_pc_button_pressed() -> void:
	openPCApp()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

#func openMediaPlayer() -> void:
	#if wmpInstance == null:
		#wmpInstance = wmpApp.instantiate()
		#add_child(wmpInstance)
		#if taskCount > 0:
			#wmpInstance.myWindow.position += Vector2i(randi_range(10,20), randi_range(10,20))
		#var tB = taskBar.openTask("WMP")
		#wmpInstance.setTaskButton(tB)
		#updateTaskCount()
	#else:
		#print("WMP ALREADY OPEN!")
		#wmpInstance.myTaskButton.set_pressed_no_signal(true)
		#wmpInstance.minimizeWindow()

func openCustomMediaPlayer() -> void:
	if wmpInstance == null:
		wmpInstance = wmpApp.instantiate()
		add_child(wmpInstance)
		wmpInstance.openWindow()
		if taskCount > 0:
			wmpInstance.myWindow.position += Vector2(randi_range(10,20), randi_range(10,20))
		var tB = taskBar.openTask("WMP")
		wmpInstance.setTaskButton(tB)
		updateTaskCount()
	else:
		print("WMP ALREADY OPEN!")
		wmpInstance.myTaskButton.set_pressed_no_signal(true)
		wmpInstance.minimizeWindow()
	updateAppIcons()

func closeCustomMediaPlayer() -> void:
	if wmpInstance != null:
		wmpInstance.closeWindow()
	#taskBar.closeTask("WMP")
	updateTaskCount()

func _on_wmp_button_pressed() -> void:
	#openMediaPlayer()
	openCustomMediaPlayer()
	MusicManager.sfx_player.play_SFX_from_library_poly("click")

func updateAppIcons() -> void:
	for p in get_children():
		if p.get("programIcon"):
			p.updateProgramIcon()
	NotepadWins.updateIcon()
