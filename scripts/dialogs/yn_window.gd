extends Control

@export var myWindow : Window
@export var dialogMSG : Label

# Buttons
@export var yesButton : Button
@export var noButton : Button

@export var altDisabledIcon : Texture2D
@export var coolMessage : bool = false
@export var dialogButton : TextureButton

# Signal
signal yesPress
signal noPress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.sfx_player.play_SFX_from_library_poly("notify")
	pass

func setTitle(winTitle : String) -> void:
	myWindow.title = winTitle

func setMessage(msg : String) -> void:
	dialogMSG.text = msg

func toggleCoolMessage() -> void:
	coolMessage = not coolMessage
	if coolMessage:
		dialogButton.texture_disabled = altDisabledIcon

func _on_theme_changed() -> void:
	myWindow.theme = theme

func _on_window_close_requested() -> void:
	queue_free()

func _on_no_pressed() -> void:
	noPress.emit()
	_on_window_close_requested()

func _on_yes_pressed() -> void:
	yesPress.emit()
	_on_window_close_requested()
