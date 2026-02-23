extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
@export var textPanel : TextEdit
var isMinimize : bool = false

# Status Bar Labels
@export var LineNum : Label
@export var ColNum : Label
@export var CharCount : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	theme = globalParameters.defaultWindowTheme

func setTextStatic(msg : String) -> void:
	textPanel.editable = true
	textPanel.text = msg
	textPanel.editable = false
	updateStatusBar()

func setTextFree(msg : String) -> void:
	textPanel.editable = true
	textPanel.text = msg
	updateStatusBar()

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

func updateStatusBar() -> void:
	var lineInt : int = textPanel.get_caret_line() + 1
	var colInt : int = textPanel.get_caret_column() + 1
	var charCountInt : int = 0
	
	if textPanel.get_selected_text().length() > 0:
		charCountInt = textPanel.get_selected_text().length()
	else:
		charCountInt = textPanel.text.length()
	
	# Format String
	LineNum.text = "Ln " + str(lineInt)
	ColNum.text = "Col " + str(colInt)
	CharCount.text = str(charCountInt) + " Characters"

func _on_text_edit_caret_changed() -> void:
	updateStatusBar()
