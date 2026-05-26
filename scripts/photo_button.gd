extends MarginContainer

@export var pButton : TextureButton
@export var pLabel : Label

var photoTexture : Texture2D
var photoName : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if photoTexture:
		pButton.texture_normal = photoTexture
	if photoName:
		pLabel.text = photoName

func setPhoto(w : Texture2D) -> void:
	pButton.texture_normal = w

func setLabel(n : String) -> void:
	pLabel.text = n
