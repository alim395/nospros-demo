extends Resource
class_name AudioLibrary

@export var soundEffects: Array[SFX]

func _get_audio_stream(_tag: String):
	var index = -1
	if _tag:
		for s in soundEffects:
			index += 1
			if s.tag == _tag:
				break
		return soundEffects[index].stream
	else:
		printerr("TAG INVALID OR NOT PROVIDED")
	return null
