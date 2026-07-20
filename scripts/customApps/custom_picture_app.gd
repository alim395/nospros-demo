extends customWindow

@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var desktopWallpaper : TextureRect
@export var defaultWallpaper : Texture2D
var wallpaperPath : String = "res://sprites/backgrounds/wallpapers/"

@export var folderRows : FlowContainer
var pBScene: PackedScene = preload("res://scenes/buttons/photoButton.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if desktopWallpaper:
		if globalParameters.defaultWallpaper:
			desktopWallpaper.texture = globalParameters.defaultWallpaper
		else:
			desktopWallpaper.texture = defaultWallpaper
	setProgamIcon(globalParameters.icon_dict.get("Picture"))
	generatePhotoButtons()

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

func _on_photo_button_pressed(source: TextureButton) -> void:
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	globalParameters.defaultWallpaper = source.texture_normal
	if desktopWallpaper:
		desktopWallpaper.texture = globalParameters.defaultWallpaper

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func openWindow() -> void:
	myWindow.visible = true
	_on_window_container_focus_entered()

func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	closeWindow()

func closeWindow() -> void:
	myWindow.visible = false
	if get_parent():
		%AppManager.taskBar.closeTask("Picture")

func _on_minimize_button_button_up() -> void:
	super._on_minimize_button_button_up()
	if myTaskButton:
		myTaskButton.button_pressed = false

func minimizeWindow() -> void:
	if myTaskButton:
		isMinimize = true
		myWindow.visible = not isMinimize
		if myTaskButton.button_pressed:
			isMinimize = false
			myWindow.visible = not isMinimize
			myWindow.grab_focus()

func updateProgramIcon() -> void:
	setProgamIcon(globalParameters.icon_dict.get("Picture"))
