extends AudioStreamPlayer

@export var audioLibrary: AudioLibrary
@export var maxPolyphony := 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = maxPolyphony

func play_SFX_from_library_poly(_tag: String) -> void:
	if _tag:
		var audioStream = audioLibrary._get_audio_stream(_tag)
		if !playing: self.play()
		
		var polyphonicStreamPlayback := self.get_stream_playback()
		polyphonicStreamPlayback.play_stream(audioStream)
	else:
		printerr("TAG INVALID OR NOT PROVIDED")

func play_SFX_from_library(_tag: String) -> void:
	if _tag:
		var audioStream = audioLibrary._get_audio_stream(_tag)
		self.stop()
		self.play()
		
		var polyphonicStreamPlayback := self.get_stream_playback()
		polyphonicStreamPlayback.play_stream(audioStream)
	else:
		printerr("TAG INVALID OR NOT PROVIDED")
