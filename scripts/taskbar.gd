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
			buttonContainer.theme = globalParameters.LunaTask
			globalParameters.defaultWindowTheme = globalParameters.LunaTheme
		globalParameters.TaskThemes.OliveGreen:
			StartButton.texture_normal = startButtonTextures.OliveGreenTextures[0]
			StartButton.texture_pressed = startButtonTextures.OliveGreenTextures[2]
			StartButton.texture_hover = startButtonTextures.OliveGreenTextures[1]
			buttonContainer.theme = globalParameters.OliveTask
			globalParameters.defaultWindowTheme = globalParameters.OliveTheme
		globalParameters.TaskThemes.Embedded:
			StartButton.texture_normal = startButtonTextures.EmbeddedTextures[0]
			StartButton.texture_pressed = startButtonTextures.EmbeddedTextures[2]
			StartButton.texture_hover = startButtonTextures.EmbeddedTextures[1]
			buttonContainer.theme = globalParameters.EmbeddedTask
			globalParameters.defaultWindowTheme = globalParameters.EmbeddedTheme
		globalParameters.TaskThemes.Metallic:
			StartButton.texture_normal = startButtonTextures.MetallicTextures[0]
			StartButton.texture_pressed = startButtonTextures.MetallicTextures[2]
			StartButton.texture_hover = startButtonTextures.MetallicTextures[1]
			buttonContainer.theme = globalParameters.MetallicTask
			globalParameters.defaultWindowTheme = globalParameters.MetallicTheme
		globalParameters.TaskThemes.Royale:
			StartButton.texture_normal = startButtonTextures.RoyaleTextures[0]
			StartButton.texture_pressed = startButtonTextures.RoyaleTextures[2]
			StartButton.texture_hover = startButtonTextures.RoyaleTextures[1]
			buttonContainer.theme = globalParameters.RoyaleTask
			globalParameters.defaultWindowTheme = globalParameters.RoyaleTheme
		globalParameters.TaskThemes.ZunaRoyaleNoir:
			StartButton.texture_normal = startButtonTextures.RoyaleNoirTextures[0]
			StartButton.texture_pressed = startButtonTextures.RoyaleNoirTextures[2]
			StartButton.texture_hover = startButtonTextures.RoyaleNoirTextures[1]
			buttonContainer.theme = globalParameters.ZuneTask
			globalParameters.defaultWindowTheme = globalParameters.ZuneTheme
	
	# Update Current Sprite
	currentTheme = globalParameters.TaskThemes.get(themeName)
	
	# Update Global Parameter
	globalParameters.defaultTheme = currentTheme
	
	# Updata AppManager
	%AppManager.updateTheme()

func _on_start_button_pressed() -> void:
	startMenu.visible = not startMenu.visible

func _on_power_options_pressed() -> void:
	startMenu.visible = false

func openTask(task : String) -> taskbarButton:
	var tB = taskbarButton.new(task)
	tB.pressed.connect(focusTask.bind(task))
	tB.toggle_mode = true
	tB.set_pressed(true)
	tB.set_task(task)
	buttonContainer.add_child(tB)
	focusTask(task)
	return tB

func closeTask(task: String) -> void:
	if buttonContainer.get_children():
		for tB in buttonContainer.get_children():
			if tB.text == task:
				tB.queue_free()

func _on_visibility_changed() -> void:
	if myCanvas != null:
		myCanvas.visible = self.visible

func focusTask(task : String) -> void:
	if buttonContainer.get_children():
		for tB in buttonContainer.get_children():
			if tB.taskName == task:
				pass
			else:
				tB.set_pressed_no_signal(false)
