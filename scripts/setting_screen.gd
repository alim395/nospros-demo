extends Control

@export var softBlur : ColorRect
@export var highFidelity : CheckButton
@export var crtFilter : CheckButton
#@export var crtNode : CRT
#@export var ScreenFilters : Node2D
#@export var startMenuOptions : OptionButton
#@export var iconStyleOptions : OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#ScreenFilters.visible = true;
	#softBlur.visible = not globalParameters.highFidelity
	#crtNode.visible = globalParameters.crtFilter
	highFidelity.button_pressed = globalParameters.highFidelity
	crtFilter.button_pressed = globalParameters.crtFilter

func _on_check_button_toggled(toggled_on: bool) -> void:
	#softBlur.visible = not toggled_on
	globalParameters.highFidelity = toggled_on
	print("SOFT TOGGLED")

func _on_crt_button_toggled(toggled_on: bool) -> void:
	#crtNode.visible = toggled_on
	globalParameters.crtFilter = toggled_on
	print("CRT TOGGLED")
