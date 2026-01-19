extends Control

class_name Taskbar

var defaultTheme = globalParameters.defaultTheme
var currentTheme = defaultTheme

@export var myCanvas : CanvasLayer

#@export var barSprites : Array[Sprite2D]
@export var barTexture : TextureRect
@export var barTextureArray : Array[Texture2D]
@export var StartButton : TextureButton
@export var startButtonTextures : Resource
@export var startMenu : Control

@export var buttonContainer : HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	defaultTheme = globalParameters.defaultTheme
	changeTheme(defaultTheme, globalParameters.TaskThemes.find_key(int(defaultTheme)))
	startMenu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func changeTheme(themeIndex : globalParameters.TaskThemes, themeName := "Luna") -> void:
	## Switch barSprite
	#for s in barSprites:
		#s.visible = false
	#barSprites[int(themeIndex)].visible = true
	
	# Switch barTexture
	barTexture.texture = barTextureArray[int(themeIndex)]
	
	# Switch Start Button Textures
	match themeIndex :
		globalParameters.TaskThemes.Luna:
			StartButton.texture_normal = startButtonTextures.LunaTextures[0]
			StartButton.texture_pressed = startButtonTextures.LunaTextures[2]
			StartButton.texture_hover = startButtonTextures.LunaTextures[1]
		globalParameters.TaskThemes.OliveGreen:
			StartButton.texture_normal = startButtonTextures.OliveGreenTextures[0]
			StartButton.texture_pressed = startButtonTextures.OliveGreenTextures[2]
			StartButton.texture_hover = startButtonTextures.OliveGreenTextures[1]
		globalParameters.TaskThemes.Embedded:
			StartButton.texture_normal = startButtonTextures.EmbeddedTextures[0]
			StartButton.texture_pressed = startButtonTextures.EmbeddedTextures[2]
			StartButton.texture_hover = startButtonTextures.EmbeddedTextures[1]
		globalParameters.TaskThemes.ZunaRoyaleNoir:
			StartButton.texture_normal = startButtonTextures.RoyaleNoirTextures[0]
			StartButton.texture_pressed = startButtonTextures.RoyaleNoirTextures[2]
			StartButton.texture_hover = startButtonTextures.RoyaleNoirTextures[1]
	
	# Update Current Sprite
	currentTheme = globalParameters.TaskThemes.get(themeName)
	
	# Update Global Parameter
	globalParameters.defaultTheme = currentTheme

func _on_start_button_pressed() -> void:
	startMenu.visible = not startMenu.visible

func _on_power_options_pressed() -> void:
	startMenu.visible = false

func openTask(task : String) -> taskbarButton:
	var tB = taskbarButton.new(task)
	tB.set_task(task)
	buttonContainer.add_child(tB)
	return tB

func closeTask(task: String) -> void:
	if buttonContainer.get_children():
		for tB in buttonContainer.get_children():
			if tB.text == task:
				tB.queue_free()

func _on_visibility_changed() -> void:
	if myCanvas != null:
		myCanvas.visible = self.visible
