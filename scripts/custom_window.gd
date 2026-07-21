extends Control

class_name  customWindow

@export var title : String

var isDraggable : bool = true
var isFocused : bool = false
var dragging : bool = false
var isMaximize : bool = false
@export var isSubWindow : bool = false

var mouseStartPos : Vector2i
var myWindow : Control
var maxSize : Vector2 = Vector2(640, 336)

# Title Bar
var borderPanel : PanelContainer
var borderFocus : StyleBox
var borderUnfocused : StyleBox

var closeButton : TextureButton
var maximizeButton : TextureButton
var restoreButton : TextureButton
var minimizeButton : TextureButton
@export var titleLabel : Label
var programIcon : TextureRect

# Content
var taskName : String
var contentPanel : Panel
@export var imageDisplay : TextureRect
@export var videoPlayer : VideoStreamPlayer

#@export var themeArray : Array[Theme]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	myWindow = $WindowContainer
	borderPanel = $WindowContainer/Border
	closeButton = $WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/CloseButton
	maximizeButton = $WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/MaximizeButton
	restoreButton = $WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/RestoreButton
	minimizeButton = $WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/MinimizeButton
	#titleLabel = $WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/TitleLabel
	programIcon = $WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/Icon
	contentPanel = $WindowContainer/Layout/PanelMargin/Panel
	
	if isSubWindow:
		maximizeButton.visible = false
		restoreButton.visible = false
		minimizeButton.visible = false
		programIcon.visible = false
		$WindowContainer/Layout/TitleBarContainer/MarginContainer/TitleBar/VSeparator.visible = false
	
	if title:
		titleLabel.text = title
	
	# Button Events
	closeButton.pressed.connect(titleButtonPressed)
	maximizeButton.pressed.connect(titleButtonPressed)
	restoreButton.pressed.connect(titleButtonPressed)
	minimizeButton.pressed.connect(titleButtonPressed)
	
	#_on_restore_button_button_up()
	theme = globalParameters.defaultWindowTheme
	updateTheme()
	myWindow.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("DEBUG_ChangeTheme"):
		#var randomIndex : int = randi_range(0, themeArray.size() - 1)
		#theme = themeArray[randomIndex]
	pass
	
func _on_title_bar_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not dragging:
				mouseStartPos = get_viewport().get_mouse_position()
			dragging = event.is_pressed()
		myWindow.grab_focus()
	dragWindow(event)

func dragWindow(event):
	if dragging:
		if isDraggable:
			if event is InputEventMouseMotion:
				myWindow.position += event.relative

func titleButtonPressed():
	myWindow.grab_focus()
	
func _on_close_button_button_up() -> void:
	if isMaximize:
		_on_restore_button_button_up()
	print("CLOSING")

func _on_maximize_button_button_up() -> void:
	print("MAXIMIZE")
	myWindow.visible = false
	isDraggable = false
	# CENTER A DIV HAHAHAHAHA
	myWindow.anchor_left = 0
	myWindow.anchor_right = 0
	myWindow.anchor_top = 0
	myWindow.anchor_bottom = 0
	myWindow.offset_left = 0
	myWindow.offset_right = 0
	myWindow.offset_top = 0
	myWindow.offset_bottom = 0	
	myWindow.size = maxSize
	myWindow.position = Vector2.ZERO
	myWindow.visible = true
	toggleMax()

func toggleMax() -> void:
	isMaximize = not isMaximize
	$WindowContainer/Handles.toggleUnresziable()
	maximizeButton.visible = not isMaximize
	restoreButton.visible = isMaximize

func _on_restore_button_button_up() -> void:
	print("UNMAXIMIZE")
	myWindow.visible = false
	isDraggable = true
	myWindow.size = Vector2(1,1)
	# CENTER A DIV HAHAHAHAHA
	myWindow.anchor_left = 0.5
	myWindow.anchor_right = 0.5
	myWindow.anchor_top = 0.5
	myWindow.anchor_bottom = 0.5
	myWindow.offset_left = -myWindow.size.x / 2
	myWindow.offset_right = myWindow.size.x / 2
	myWindow.offset_top = -myWindow.size.y / 2
	myWindow.offset_bottom = myWindow.size.y / 2
	myWindow.size = Vector2(1,1)
	myWindow.visible = true
	toggleMax()

func _on_minimize_button_button_up() -> void:
	print("MINIMIZE")
	myWindow.visible = false
	release_focus()

func _on_window_container_focus_entered() -> void:
	#z_index = 1
	#top_level = true
	if get_parent() and get_parent().is_node_ready():
		get_parent().move_child(self, -1)
		#print(get_parent().name)
		#print(self.name)
	borderPanel.remove_theme_stylebox_override("panel")
	borderPanel.add_theme_stylebox_override("panel",borderFocus)
	isFocused = true
	print("GOT FOCUS")

func _on_window_container_focus_exited() -> void:
	#z_index = 0
	#top_level = false
	borderPanel.remove_theme_stylebox_override("panel")
	borderPanel.add_theme_stylebox_override("panel",borderUnfocused)
	isFocused = false
	print("LOST FOCUS")

func _on_window_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		myWindow.grab_focus()

func _on_window_container_resized() -> void:
	size.clamp(get_minimum_size(), maxSize)

func updateTheme() -> void:
	if theme:
		print("Updating THEME")
		# Border
		borderFocus = theme.get_stylebox("border", "customWindow")
		borderUnfocused = theme.get_stylebox("borderUnfocused", "customWindow")
		if isFocused:
			borderPanel.add_theme_stylebox_override("panel",borderFocus)
		else:
			borderPanel.add_theme_stylebox_override("panel",borderUnfocused)
		# TitleBar
		titleLabel.add_theme_color_override("font_color",theme.get_color("title_color", "Window"))
		#titleLabel.add_theme_color_override("font_outline_color",theme.get_color("title_color_modulate", "Window"))
		# Buttons
		closeButton.texture_normal = theme.get_icon("close","Window")
		closeButton.texture_hover = theme.get_icon("close_hover","Window")
		closeButton.texture_pressed = theme.get_icon("close_pressed","Window")
		
		maximizeButton.texture_normal = theme.get_icon("maximize","customWindow")
		maximizeButton.texture_hover = theme.get_icon("maximize_hover","customWindow")
		maximizeButton.texture_pressed = theme.get_icon("maximize_pressed","customWindow")
		
		restoreButton.texture_normal = theme.get_icon("restore","customWindow")
		restoreButton.texture_hover = theme.get_icon("restore_hover","customWindow")
		restoreButton.texture_pressed = theme.get_icon("restore_pressed","customWindow")
		
		minimizeButton.texture_normal = theme.get_icon("minimize","customWindow")
		minimizeButton.texture_hover = theme.get_icon("minimize_hover","customWindow")
		minimizeButton.texture_pressed = theme.get_icon("minimize_pressed","customWindow")

func _on_theme_changed() -> void:
	if is_node_ready():
		updateTheme()

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		myWindow.grab_focus()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		myWindow.release_focus()

func setProgamIcon(icon : Texture2D) -> void:
	programIcon.texture = icon

func setTitle(titleString : String) -> void:
	print(titleString)
	if titleLabel:
		titleLabel.text = titleString
	else:
		print("titleLabel is missing???")

func setTaskName(taskNameString : String) -> void:
	taskName = taskNameString

func addContent(n : Node) -> void:
	borderPanel.add_child(n)
