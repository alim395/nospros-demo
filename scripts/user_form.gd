extends Control

@export var userProfilePics : Array[Texture2D]
@export var PFP : TextureRect
@export var playerNameInput : LineEdit
@export var userNameInput : LineEdit

var pfpIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if userProfilePics != null:
		PFP.texture = userProfilePics[0]
	playerNameInput.text = globalParameters.playerName
	userNameInput.text = globalParameters.playerUser

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pfp_prev_pressed() -> void:
	if pfpIndex > 0:
		pfpIndex -= 1
	PFP.texture = userProfilePics[pfpIndex]

func _on_pfp_next_pressed() -> void:
	if pfpIndex < (userProfilePics.size() - 1):
		pfpIndex += 1
	PFP.texture = userProfilePics[pfpIndex]

func _on_start_pressed() -> void:
	# Update Global Parameters
	if not playerNameInput.text.is_empty():
		globalParameters.playerName = playerNameInput.text
	if not userNameInput.text.is_empty():
		globalParameters.playerUser = userNameInput.text
	globalParameters.playerPFP = PFP.texture
