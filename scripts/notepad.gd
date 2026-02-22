extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
@export var textPanel : TextEdit
var isMinimize : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	theme = globalParameters.defaultWindowTheme

func setTextStatic(msg : String) -> void:
	textPanel.editable = true
	textPanel.text = msg
	textPanel.editable = false

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

func _on_window_close_requested() -> void:
	globalParameters.closeApp("notes")
	queue_free()

func _on_theme_changed() -> void:
	myWindow.theme = theme
