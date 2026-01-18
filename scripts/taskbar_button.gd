extends Button

class_name taskbarButton

@export var taskIcon : Texture2D
@export var taskName : String

# Called when the node enters the scene tree for the first time.
func _init(taskNameString : String = "Untitled") -> void:
	if taskNameString != null:
		taskName = taskNameString
		set_text(taskNameString)
		add_theme_font_size_override("font_size", 8)
		add_theme_constant_override("icon_max_width", 16)

func _ready() -> void:
	if taskIcon != null:
		icon = taskIcon
	if taskName != null:
		text = taskName

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_task(taskName : String) -> void:
	text = taskName
	if globalParameters.icon_dict.get(taskName):
		icon = globalParameters.icon_dict.get(taskName)
