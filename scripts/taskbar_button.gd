extends Button

class_name taskbarButton

@export var taskIcon : Texture2D
@export var taskName : String
var activetask : bool

# Called when the node enters the scene tree for the first time.
func _init(taskNameString : String = "Untitled") -> void:
	if taskNameString != null:
		taskName = taskNameString
		set_text(taskNameString)
		add_theme_font_size_override("font_size", 8)
		add_theme_constant_override("icon_max_width", 16)
	activetask = true

func _ready() -> void:
	if taskIcon != null:
		icon = taskIcon
	if taskName != null:
		text = taskName

func set_task(taskSetName : String) -> void:
	text = taskSetName
	if globalParameters.icon_dict.get(taskSetName):
		icon = globalParameters.icon_dict.get(taskSetName)

#func set_task_name(ptaskName : String) -> void:
	#taskName = ptaskName
