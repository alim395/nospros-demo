extends Control

@export var myWindow : Window
@export var fileNameInput : LineEdit

# Buttons
@export var saveButton : Button
@export var cancelButton : Button

# Properties
var fName : String

# Signal
signal savePress
signal cancelPress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	saveButton.disabled = true

func setTitle(winTitle : String) -> void:
	myWindow.title = winTitle

func _on_theme_changed() -> void:
	myWindow.theme = theme

func _on_window_close_requested() -> void:
	cancelPress.emit()
	queue_free()

func _on_save_pressed() -> void:
	savePress.emit(fName)
	_on_window_close_requested()

func _on_file_name_input_text_changed(new_text: String) -> void:
	if not new_text.is_empty():
		saveButton.disabled = false
		fName = new_text
	else:
		saveButton.disabled = true

func _on_cancel_pressed() -> void:
	cancelPress.emit()
	_on_window_close_requested()
