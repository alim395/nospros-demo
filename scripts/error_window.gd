extends Window

@export var titleBarName : String
@export var error_button : BaseButton
@export var errorLabel : Label
@export var error_msg : String
@export var error_sound : AudioStream
@export var note_sound : AudioStream

var localErrorCount := 0
var troll := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(globalParameters.errorCount >= 10):
		print("ACTIVATE TROLL MODE")
		troll = true
		globalParameters.trollMode = true
	if not troll:
		title = titleBarName
		errorLabel.text = error_msg
		error_button.disabled = false
		MusicManager.sfx_player.stream = error_sound
		MusicManager.sfx_player.play()
		globalParameters.errorCount += 1
	else:
		title = "SECRET UNLOCKED!"
		errorLabel.text = "Click OK to recieve you prize :D"
		error_button.disabled = true
		MusicManager.sfx_player.stream = note_sound
		MusicManager.sfx_player.play()

func _on_error_button_pressed() -> void:
	if not troll:
		MusicManager.sfx_player.stream = error_sound
		MusicManager.sfx_player.play()
		globalParameters.errorCount += 1
		print(globalParameters.errorCount)
	else:
		MusicManager.sfx_player.stream = note_sound
		MusicManager.sfx_player.play()
		globalParameters.errorCount += 1
		queue_free()
	# Update TROLL
	if globalParameters.errorCount >= 10:
		troll = true
		globalParameters.trollMode = true

func setMessage(msg : String) -> void:
	errorLabel.text = msg

func setButtonTexture(tex : Texture2D, clickable := false) -> void:
	error_button.texture_normal = tex
	error_button.disabled = not clickable

func _on_ok_pressed() -> void:
	if troll:
		globalParameters.activateTroll()
	print("GET TROLLED")
	queue_free()

func _on_close_requested() -> void:
	queue_free()
