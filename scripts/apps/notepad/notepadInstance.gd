class_name notepadInstance

# Properties
@export var fileName : String
@export var fileText : String

func _init(fName : String = "Untitled", fText : String = "Hello World!") -> void:
	fileName = fName
	fileText = fText

func setName(fName : String) -> void:
	fileName = fName

func getName() -> String:
	return fileName

func setText(fText : String) -> void:
	fileText = fText

func getText() -> String:
	return fileText
