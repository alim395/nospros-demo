extends Window

@export var masterVol : VSlider
@export var masterMute : CheckBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	masterVol.value = AudioServer.get_bus_volume_linear(0)
	masterMute.button_pressed = AudioServer.is_bus_mute(0)

func _on_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_mute_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	masterVol.editable = not toggled_on

func _on_vol_slider_drag_ended(_value_changed: bool) -> void:
	MusicManager.sfx_player.play_SFX_from_library_poly("ding")
