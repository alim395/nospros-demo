extends customWindow

var isMinimize : bool = false

@export_multiline var myPCInfo : String
@export var sysinfoLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	var pN = globalParameters.playerName
	sysinfoLabel.text = myPCInfo.replacen("PLAYERNAME", pN)

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func openWindow() -> void:
	myWindow.visible = true
	_on_window_container_focus_entered()

func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	closeWindow()

func closeWindow() -> void:
	myWindow.visible = false
	if myTaskButton:
		myTaskButton.close_task()

func _on_minimize_button_button_up() -> void:
	super._on_minimize_button_button_up()
	if myTaskButton:
		myTaskButton.button_pressed = false

func minimizeWindow() -> void:
	if myTaskButton:
		isMinimize = true
		myWindow.visible = not isMinimize
		if myTaskButton.button_pressed:
			isMinimize = false
			myWindow.visible = not isMinimize
			myWindow.grab_focus()

func updateProgramIcon() -> void:
	setProgamIcon(globalParameters.icon_dict.get("Picture"))
