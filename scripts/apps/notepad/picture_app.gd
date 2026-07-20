extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false
var isMaximize : bool = false
var prevSize : Vector2i
var maxSize : Vector2i = Vector2i(634, 304)

@export var desktopWallpaper : TextureRect
@export var defaultWallpaper : Texture2D
var wallpaperPath : String = "res://sprites/backgrounds/wallpapers/"

@export var folderRows : HFlowContainer
var pBScene: PackedScene = preload("res://scenes/buttons/photoButton.tscn")

# Constant Limits
const ROWLIMIT = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prevSize = myWindow.get_size_with_decorations()
	if globalParameters.defaultWallpaper:
		desktopWallpaper.texture = globalParameters.defaultWallpaper
	else:
		desktopWallpaper.texture = defaultWallpaper
	generatePhotoButtons()

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

func maximizeWindow() -> void:
	isMaximize = not isMaximize
	if isMaximize:
		print("MAXIMIZE")
		myWindow.visible = false
		myWindow.size = maxSize
		myWindow.unresizable = true
		minimizeWindow()
	else:
		print("UNMAXIMIZE")
		myWindow.visible = false
		myWindow.unresizable = false
		myWindow.size = prevSize
		minimizeWindow()

func _on_photo_button_pressed(source: TextureButton) -> void:
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	globalParameters.defaultWallpaper = source.texture_normal
	desktopWallpaper.texture = globalParameters.defaultWallpaper

func _on_theme_changed() -> void:
	myWindow.theme = globalParameters.defaultWindowTheme

func generatePhotoButtons() -> void:
	if ResourceLoader.list_directory(wallpaperPath):
		var photoNames : PackedStringArray = ResourceLoader.list_directory(wallpaperPath)
		for p in photoNames:
			# Ignore Directories
			if p.contains("/"):
				continue
			var photo : Texture2D = ResourceLoader.load(wallpaperPath + p) as Texture2D
			if photo:
				var pB = pBScene.instantiate()
				pB.call("setPhoto", photo)
				var pName : String = p.split(".")[0].replace("_", " ")
				pB.call("setLabel", pName)
				var pBButton : TextureButton = pB.pButton
				if pBButton:
					pBButton.connect("pressed", _on_photo_button_pressed.bind(pBButton))
				folderRows.add_child(pB)

func _on_window_size_changed() -> void:
	if not isMaximize:
		print(myWindow.size)
		#prevSize = myWindow.size

#func _on_window_window_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			#print("DOUBLE CLICK")
			#maximizeWindow()
