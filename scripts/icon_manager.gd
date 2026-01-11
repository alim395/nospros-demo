extends Control

@export var browserAppButton := TextureButton
@export var musicAppButton := TextureButton
@export var pictureAppButton := TextureButton
@export var settingAppButton := TextureButton
@export var errorAppButton := TextureButton

# Icons
@export var classicIcons : Array[Texture2D]
@export var YTKIcons : Array[Texture2D]

var defaultStyle := globalParameters.defaultButtonStyle
var currentStyle = defaultStyle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Default = ", globalParameters.defaultButtonStyle)
	print("Current = ", currentStyle)
	defaultStyle = globalParameters.defaultButtonStyle
	changeStyle(defaultStyle)
	visible = false

func setButtonClassic() -> void:
	print("CLASSIC STYLE!")
	browserAppButton.texture_normal = classicIcons[0]
	musicAppButton.texture_normal = classicIcons[1]
	pictureAppButton.texture_normal = classicIcons[2]
	settingAppButton.texture_normal = classicIcons[3]
	errorAppButton.texture_normal = classicIcons[4]
	
func setButtonY2K() -> void:
	print("Y2K STYLE!")
	browserAppButton.texture_normal = YTKIcons[0]
	musicAppButton.texture_normal = YTKIcons[1]
	pictureAppButton.texture_normal = YTKIcons[2]
	settingAppButton.texture_normal = YTKIcons[3]
	errorAppButton.texture_normal = YTKIcons[4]

func changeStyle(styleIndex : globalParameters.buttonStyle) -> void:
	print("Change Style to : ", styleIndex)
	match styleIndex:
		globalParameters.buttonStyle.Classic:
			setButtonClassic()
			print(styleIndex)
		globalParameters.buttonStyle.Y2K:
			setButtonY2K()
			print(styleIndex)
		_:
			setButtonClassic()
			print("UNIDENTIFIED STYLE")
			print(styleIndex)
	
	# Update Global Parameters
	globalParameters.defaultButtonStyle = styleIndex
	currentStyle = globalParameters.defaultButtonStyle
