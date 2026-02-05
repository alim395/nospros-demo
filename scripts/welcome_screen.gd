extends Control

@export var pfp : TextureRect
@export var nameLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if globalParameters.playerPFP != null:
		pfp.texture = globalParameters.playerPFP
	nameLabel.text = globalParameters.playerName
