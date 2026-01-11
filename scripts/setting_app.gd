extends Control

@export var myWindow : Window
@export var softBlur : ColorRect
@export var highFidelity : CheckButton
@export var crtFilter : CheckButton
@export var crtNode : CRT
@export var startMenuOptions : OptionButton
@export var iconStyleOptions : OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highFidelity.button_pressed = globalParameters.highFidelity
	crtFilter.button_pressed = globalParameters.crtFilter
	populateStartMenuThemes()
	populateIconStyles()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_window_close_requested() -> void:
	myWindow.visible = false

func openWindow() -> void:
	myWindow.visible = true

func _on_check_button_toggled(toggled_on: bool) -> void:
	softBlur.visible = not toggled_on
	globalParameters.highFidelity = toggled_on

func populateStartMenuThemes() -> void:
	for sTheme in globalParameters.TaskThemes:
		startMenuOptions.add_item(sTheme)
	if(startMenuOptions.item_count > 0):
		startMenuOptions.select(globalParameters.defaultTheme)

func populateIconStyles() -> void:
	for iStyle in globalParameters.buttonStyle:
		iconStyleOptions.add_item(iStyle)
	if(iconStyleOptions.item_count > 0):
		iconStyleOptions.select(globalParameters.defaultButtonStyle)

func _on_start_menu_theme_item_selected(index: int) -> void:
	%Taskbar.changeTheme(index, globalParameters.TaskThemes.find_key(index))

func _on_icon_style_item_selected(index: int) -> void:
	%IconManager.changeStyle(index)
	print("Index Selected: ", index)

func _on_crt_button_toggled(toggled_on: bool) -> void:
	crtNode.visible = toggled_on
	globalParameters.crtFilter = toggled_on
