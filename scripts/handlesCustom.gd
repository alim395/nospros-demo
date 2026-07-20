extends Control

var resizing : bool = false
var resize_node : Node
@export var unresizable : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var handles : Array[Control] = [$Top, $Bottom, $Left, $Right, $TLCorner, $BLCorner, $TRCorner, $BRCorner]
	for handle in handles:
		handle.gui_input.connect(func(event):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					if !resizing: resize_node = handle
					resizing = event.is_pressed()
					get_parent().grab_focus())
	updateHandleIcons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	if resizing:
		if not unresizable:
			if event is InputEventMouseMotion:
				if resize_node in [$Top, $TLCorner, $TRCorner]:
					if event.relative.y != 0:
						var currentY = get_parent().size.y
						get_parent().size.y -= int(event.relative.y)
						if get_parent().size.y != currentY:
							get_parent().position.y += int(event.relative.y)
				if resize_node in [$Bottom, $BLCorner, $BRCorner]:
					if event.relative.y != 0:
						get_parent().size.y += int(event.relative.y)
						#print(get_parent().size.y)
				if resize_node in [$Right, $TRCorner, $BRCorner]:
					if event.relative.x != 0:
						get_parent().size.x += int(event.relative.x)
						#print(get_parent().size.x)
				if resize_node in [$Left, $TLCorner, $BLCorner]:
					if event.relative.x != 0:
						var currentX = get_parent().size.x
						get_parent().size.x -= int(event.relative.x)
						if get_parent().size.x != currentX:
							get_parent().position.x += int(event.relative.x)

func toggleUnresziable():
	unresizable = not unresizable

func updateHandleIcons():
	var handles : Array[Control] = [$Top, $Bottom, $Left, $Right, $TLCorner, $BLCorner, $TRCorner, $BRCorner]
	if unresizable:
		for h in handles:
			h.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
