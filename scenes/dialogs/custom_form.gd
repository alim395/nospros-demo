extends customWindow

@export var fileNameInput : LineEdit

# Buttons
@export var saveButton : Button
@export var cancelButton : Button

# Signal
signal savePress
signal cancelPress

# Properties
var fName : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	saveButton.disabled = true

func setTitle(winTitle : String) -> void:
	titleLabel.text = winTitle
	print(winTitle)

func _on_save_pressed() -> void:
	savePress.emit(fName)
	_on_close_button_button_up()

func _on_cancel_pressed() -> void:
	cancelPress.emit()
	_on_close_button_button_up()

func _on_file_name_input_text_changed(new_text: String) -> void:
	if not new_text.is_empty():
		saveButton.disabled = false
		fName = new_text
	else:
		saveButton.disabled = true


func _on_close_button_button_up() -> void:
	cancelPress.emit()
	super._on_close_button_button_up()
	queue_free()
