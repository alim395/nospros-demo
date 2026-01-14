extends Control

@export var myWindow : Window
@export var desktopWallpaper : Sprite2D
@export var wallpapersCollection : Array[Texture2D]
@export var wallpapersCollectionName : Array[String]
@export var folderRows : Control
@export var defaultWallpaper := globalParameters.defaultWallpaperIndex

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	desktopWallpaper.texture = wallpapersCollection.get(defaultWallpaper)
	#populateFolder()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_window_close_requested() -> void:
	myWindow.visible = false

func openWindow() -> void:
	myWindow.visible = true

#func populateFolder() -> void:
	#var count = 0
	#var row = 0
	#var row0Photos = folderRows.get_node("Row0").get_children(true)
	#var row1Photos = folderRows.get_node("Row1").get_children(true)
	#
	#if wallpapersCollectionName.size() != wallpapersCollection.size():
		#wallpapersCollectionName.resize(wallpapersCollection.size())
		#for n in wallpapersCollectionName:
			#if n == null:
				#n = "Unknown"
	#
	#for wallpaper in wallpapersCollection:
		#if count == 3:
			#row = 1
		#if row == 0:
			#var photoButton = row0Photos[count].get_child(0).get_child(0)
			#var photoName = row0Photos[count].get_child(0).get_child(1)
			#photoButton.texture_normal = wallpapersCollection.get(count)
			#photoName.text = wallpapersCollectionName[count]
		#elif row == 1:
			#var rowCount = count - 3
			#var photoButton = row1Photos[rowCount].get_child(0).get_child(0)
			#var photoName = row1Photos[rowCount].get_child(0).get_child(1)
			#photoButton.texture_normal = wallpapersCollection.get(count)
			#photoName.text = wallpapersCollectionName[count]

func _on_photo_pressed(photoNum: int) -> void:
	MusicManager.sfx_player.play_SFX_from_library_poly("click")
	desktopWallpaper.texture = wallpapersCollection.get(photoNum)
	globalParameters.defaultWallpaperIndex = photoNum
