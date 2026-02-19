extends Control

@export var myWindow : Window
@export var errorButton : TextureButton
@export var errorLabel : Label
@export var errorTextures : Array[Texture2D]

var secret1 : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	myWindow.theme = globalParameters.defaultWindowTheme
	if globalParameters.errorCount == 10:
		MusicManager.sfx_player.play_SFX_from_library_poly("notify")
		unlockSecret()
	else:
		MusicManager.sfx_player.play_SFX_from_library_poly("error")
	globalParameters.errorCount += 1

func setErrorType(eType : int) -> void:
	if eType == globalParameters.errorType.critical:
		errorButton.disabled = false
	if eType == globalParameters.errorType.alert:
		errorButton.disabled = true

func setErrorMessage(msg : String) -> void:
	errorLabel.text = msg

func _on_window_close_requested() -> void:
	queue_free()

func _on_ok_pressed() -> void:
	if(secret1):
		globalParameters.activateTroll()
		secret1 = false
	queue_free()

func _on_error_button_pressed() -> void:
	if globalParameters.errorCount == 10:
		MusicManager.sfx_player.play_SFX_from_library_poly("notify")
		unlockSecret()
	else:
		MusicManager.sfx_player.play_SFX_from_library_poly("error")
	globalParameters.errorCount += 1

func unlockSecret() -> void:
	setErrorType(globalParameters.errorType.alert)
	setErrorMessage("SECRET UNLOCKED!")
	secret1 = true
	globalParameters.trollMode = true
