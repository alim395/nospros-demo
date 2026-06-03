extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton

# Sub Task Icons
@export var vTIcon : Texture2D

var isMinimize : bool = false

@export var softBlur : ColorRect
@export var highFidelity : CheckButton
@export var crtFilter : CheckButton
@export var fullScreen : CheckButton
@export var crtNode : CRT
@export var startMenuOptions : OptionButton
@export var iconStyleOptions : OptionButton
@export var taskBar : Taskbar

@onready var volumeControl = preload("res://scenes/volume.tscn")
var vc : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highFidelity.button_pressed = globalParameters.highFidelity
	crtFilter.button_pressed = globalParameters.crtFilter
	populateStartMenuThemes()
	populateIconStyles()
	
	# Check if fullscreen:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullScreen.button_pressed = true
	else:
		fullScreen.button_pressed = false

func _on_window_close_requested() -> void:
	myWindow.visible = false
	%AppManager.taskBar.closeTask("Setting")

func openWindow() -> void:
	myWindow.visible = true

func minimizeWin() -> void:
	isMinimize = not isMinimize
	myWindow.visible = not isMinimize

func _on_check_button_toggled(toggled_on: bool) -> void:
	softBlur.visible = not toggled_on
	globalParameters.highFidelity = toggled_on

func populateStartMenuThemes() -> void:
	for sTheme in globalParameters.TaskThemes:
		startMenuOptions.add_item(sTheme)
	if(startMenuOptions.item_count > 0):
		startMenuOptions.select(globalParameters.defaultTheme)

func populateIconStyles() -> void:
	for iStyle in globalParameters.buttonStyle:
		iconStyleOptions.add_item(iStyle)
	if(iconStyleOptions.item_count > 0):
		iconStyleOptions.select(globalParameters.defaultButtonStyle)

func _on_start_menu_theme_item_selected(index: int) -> void:
	taskBar.changeTheme(index, globalParameters.TaskThemes.find_key(index))

func _on_icon_style_item_selected(index: int) -> void:
	%IconManager.changeStyle(index)
	print("Index Selected: ", index)
	taskBar.updateTaskIcons()

func _on_crt_button_toggled(toggled_on: bool) -> void:
	crtNode.visible = toggled_on
	globalParameters.crtFilter = toggled_on

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func minimizeWindow() -> void:
	isMinimize = true
	myWindow.visible = not isMinimize
	if myTaskButton.button_pressed:
		isMinimize = false
		myWindow.visible = not isMinimize
		myWindow.grab_focus()

func _on_full_screen_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_audio_button_pressed() -> void:
	if vc == null:
		vc = volumeControl.instantiate()
		var tB = taskBar.openTask("Volume Control")
		vc.setTaskButton(tB)
		tB.set_icon(vTIcon)
		add_child(vc)
	vc.openWindow()

func _on_theme_changed() -> void:
	myWindow.theme = theme
	if vc != null:
		vc.theme = theme
