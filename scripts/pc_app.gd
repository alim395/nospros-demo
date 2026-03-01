extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

# INPUT
@export_multiline var myPCInfo : String

# OUTPUT
@export var sysinfoLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pN = globalParameters.playerName
	sysinfoLabel.text = myPCInfo.replacen("PLAYERNAME", pN)

func _on_window_close_requested() -> void:
	myWindow.visible = false
	%AppManager.taskBar.closeTask("Computer")

func openWindow() -> void:
	myWindow.visible = true

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

func _on_theme_changed() -> void:
	myWindow.theme = globalParameters.defaultWindowTheme
