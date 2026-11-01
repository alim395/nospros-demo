extends PanelContainer
class_name ImageError

@export var imageLabel : RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not imageLabel:
		imageLabel = $Panel/HBoxContainer/ImageLabel

func setSize(x: float, y: float) -> void:
	custom_minimum_size = Vector2(x,y)

func setText(text : String) -> void:
	if text:
		imageLabel.text = text
