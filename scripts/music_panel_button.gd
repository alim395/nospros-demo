extends TextureButton

@export var panelVisuals : Array[Control]
var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not panelVisuals:
		queue_free()
	else:
		for v in panelVisuals:
			v.visible = false
		panelVisuals[0].visible = true

func _on_pressed() -> void:
	currentIndex += 1
	if currentIndex > panelVisuals.size() - 1:
		currentIndex = 0
	for v in panelVisuals:
		v.visible = false
	panelVisuals[currentIndex].visible = true
