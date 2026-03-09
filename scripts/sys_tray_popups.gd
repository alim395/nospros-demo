extends Control

@export var volumeButton : TextureButton
@export var volumeWindow : Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volumeWindow.set_visible(false)

func _on_volume_button_toggled(toggled_on: bool) -> void:
	volumeWindow.set_visible(toggled_on)

func _on_volume_focus_exited() -> void:
	volumeWindow.set_visible(false)
