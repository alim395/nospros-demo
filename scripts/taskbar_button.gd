extends Button

@export var taskIcon : Texture2D
@export var taskName : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if taskIcon != null:
		icon = taskIcon
	if taskName != null:
		text = taskName

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
