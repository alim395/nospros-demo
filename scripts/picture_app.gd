extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var desktopWallpaper : TextureRect
@export var defaultWallpaper : Texture2D
@export var folderRows : Control

# Constant Limits
const ROWLIMIT = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	desktopWallpaper.texture = defaultWallpaper

func _on_window_close_requested() -> void:
	myWindow.visible = false
	%AppManager.taskBar.closeTask("Picture")

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

func _on_photo_button_pressed(source: TextureButton) -> void:
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	desktopWallpaper.texture = source.texture_normal
