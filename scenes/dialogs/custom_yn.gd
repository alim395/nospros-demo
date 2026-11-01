extends customWindow

@export var dialogMSG : Label
@export var coolMessage : bool = false

@export var dialogButton : TextureButton
@export var altDisabledIcon : Texture2D

# Signal
signal yesPress
signal noPress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	MusicManager.sfx_player.play_SFX_from_library_poly("notify")

func _on_yes_pressed() -> void:
	yesPress.emit()
	_on_close_button_button_up()

func _on_no_pressed() -> void:
	noPress.emit()
	_on_close_button_button_up()

func setTitle(winTitle : String) -> void:
	titleLabel.text = winTitle
	print(winTitle)

func setMessage(msg : String) -> void:
	dialogMSG.text = msg

func toggleCoolMessage() -> void:
	coolMessage = not coolMessage
	if coolMessage:
		dialogButton.texture_disabled = altDisabledIcon

func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	queue_free()
