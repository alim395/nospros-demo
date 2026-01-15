extends Control

@export var crtNode : CRT
@export var softBlur : ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	softBlur.visible = not globalParameters.highFidelity
	crtNode.visible = globalParameters.crtFilter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visibility_changed:
		var children = get_children()
		for c in children:
			if c is not CRT:
				c.visible = self.visible

func _on_preview_button_pressed() -> void:
	self.visible = true
	await get_tree().create_timer(0.2).timeout
	softBlur.visible = not globalParameters.highFidelity
	crtNode.visible = globalParameters.crtFilter

func _on_exit_preview_pressed() -> void:
	self.visible = false
	crtNode.visible = false
