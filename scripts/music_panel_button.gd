extends TextureButton

@export var glassTap : AudioStream

@export var panelVisuals : Array[Control]
var currentIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not panelVisuals:
		queue_free()
	else:
		if not (panelVisuals.size() == 1):
			for v in panelVisuals:
				v.visible = false
			panelVisuals[0].visible = true
		else:
			queue_free()

func _on_pressed() -> void:
	currentIndex += 1
	if currentIndex > panelVisuals.size() - 1:
		currentIndex = 0
	for v in panelVisuals:
		v.visible = false
	panelVisuals[currentIndex].visible = true
	globalParameters.playSFX(glassTap)
