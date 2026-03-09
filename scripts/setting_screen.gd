extends Control

@export var softBlur : ColorRect
@export var highFidelity : CheckButton
@export var crtFilter : CheckButton
@export var fullScreen : CheckButton
#@export var crtNode : CRT
#@export var ScreenFilters : Node2D
#@export var startMenuOptions : OptionButton
#@export var iconStyleOptions : OptionButton

# Audio Sliders
@export var masterVol : HSlider
@export var musicVol : HSlider
@export var sfxVol : HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ScreenFilters.visible = true;
	#softBlur.visible = not globalParameters.highFidelity
	#crtNode.visible = globalParameters.crtFilter
	highFidelity.button_pressed = globalParameters.highFidelity
	crtFilter.button_pressed = globalParameters.crtFilter
	
	# Init Sliders
	masterVol.value = AudioServer.get_bus_volume_linear(0)
	musicVol.value = AudioServer.get_bus_volume_linear(1)
	sfxVol.value = AudioServer.get_bus_volume_linear(2)
	
	# Check if fullscreen:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullScreen.button_pressed = true
	else:
		fullScreen.button_pressed = false

func _on_check_button_toggled(toggled_on: bool) -> void:
	#softBlur.visible = not toggled_on
	globalParameters.highFidelity = toggled_on
	print("SOFT TOGGLED")

func _on_crt_button_toggled(toggled_on: bool) -> void:
	#crtNode.visible = toggled_on
	globalParameters.crtFilter = toggled_on
	print("CRT TOGGLED")

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
