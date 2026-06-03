extends Control

var windowCount : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func closeAllDialogues() -> void:
	if windowCount > 0:
		for d in get_children():
			d.queue_free()

func _on_child_entered_tree(_node: Node) -> void:
	windowCount += 1

func _on_child_exiting_tree(_node: Node) -> void:
	windowCount -= 1
