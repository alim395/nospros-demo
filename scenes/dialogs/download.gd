extends customWindow

## The "Saving..." progress dialog scene to open when Save is pressed
@export var downloadingScene : PackedScene
## Seconds the fake download takes. 0 = estimate from file size
@export var downloadDuration : float = 0.0
## Overwirte YN Dialog
@export var overwriteScene : PackedScene
## Browser Reference
var sourceBrowser : Node
var _confirmDlg : Node

@export var fileName : String:
	set(value):
		fileName = value
		_update_description()

@export var fileType : String:
	set(value):
		fileType = value
		_update_description()

@export var fileTypeLong : String:
	set(value):
		fileTypeLong = value
		_update_description()

@export var filesize_num : float = 1.0:
	set(value):
		filesize_num = maxf(value, 1.0)
		_update_description()

@export var filesize_unit : globalParameters.filesize_unit = globalParameters.filesize_unit.MB:
	set(value):
		filesize_unit = value
		_update_description()

@export var websiteSource : String:
	set(value):
		websiteSource = value
		_update_description()

@export var fileDescLabel : Label
@export var saveButton : Button
@export var cancelButton : Button

var _descTemplate : String = ""

var entry : DownloadEntry
var _saved : bool = false
var _confirming : bool = false
var _answerHandled : bool = false

func _ready() -> void:
	super._ready()
	if not fileDescLabel:
		fileDescLabel = find_child("FileDescLabel", true, false) as Label
	if not saveButton:
		saveButton = find_child("Save", true, false) as Button
	if not cancelButton:
		cancelButton = find_child("Cancel", true, false) as Button

	_descTemplate = fileDescLabel.text
	_update_description()

	saveButton.pressed.connect(_on_save_pressed)
	cancelButton.pressed.connect(_on_cancel_pressed)
	
	if sourceBrowser:
		sourceBrowser.tree_exiting.connect(_on_browser_closed)


func _update_description() -> void:
	# Setters can fire before _ready (when the scene loads exported values)
	if not is_node_ready() or _descTemplate.is_empty():
		return
	var text := _descTemplate
	# Keep LONGFILETYPE before TYPE, since TYPE is a substring of it
	if fileTypeLong:
		text = text.replace("LONGFILETYPE", fileTypeLong)
	if fileType:
		text = text.replace("TYPE", fileType)
	if fileName:
		text = text.replace("FILENAME", fileName)
	text = text.replace("FILESIZE MB", "%s %s" % [_fmt_size(filesize_num), _unit_name()])
	if websiteSource:
		text = text.replace("WEBSITESOURCE", websiteSource)
	fileDescLabel.text = text


func _on_save_pressed() -> void:
	if _saved or _confirming:
		return
	if not downloadingScene:
		push_error("DownloadWindow: downloadingScene is not assigned")
		return
	if entry == null:
		push_error("Prompt has no entry. Was applyEntry() called before add_child?")
		return

	if WebDirectory.downloadExists(entry):
		_ask_overwrite()
	else:
		_start_download()

func _on_cancel_pressed() -> void:
	super._on_close_button_button_up()
	queue_free()

# Helpers
func _unit_name() -> String:
	return globalParameters.filesize_unit.keys()[filesize_unit]

func _fmt_size(value : float) -> String:
	# Drop the ".0" on whole numbers (456 instead of 456.0)
	return str(int(value)) if is_equal_approx(value, roundf(value)) else str(value)

func _estimate_duration() -> float:
	print("Estimating Duration...")
	var megabytes : float = filesize_num
	match filesize_unit:
		globalParameters.filesize_unit.Bytes: megabytes /= 1048576.0
		globalParameters.filesize_unit.KB: megabytes /= 1024.0
		globalParameters.filesize_unit.GB: megabytes *= 1024.0
	return clampf(megabytes * 1.5, 2.0, 30.0)  # ~1.5 s per MB, clamped to 2-30 s

func applyEntry(e : DownloadEntry) -> void:
	entry = e
	fileName = e.fileName
	fileType = e.fileType
	fileTypeLong = e.fileTypeLong
	filesize_num = e.filesize_num
	filesize_unit = e.filesize_unit
	websiteSource = e.websiteSource
	if e.duration > 0.0:
		downloadDuration = e.duration

func _ask_overwrite() -> void:
	if not overwriteScene:
		push_error("DownloadWindow: overwriteScene is not assigned")
		return   # don't silently overwrite
	_confirming = true
	_answerHandled = false
	saveButton.disabled = true
	cancelButton.disabled = true

	var dlg := overwriteScene.instantiate()
	_confirmDlg = dlg
	dlg.yesPress.connect(_on_overwrite_answered.bind(true))
	dlg.noPress.connect(_on_overwrite_answered.bind(false))
	dlg.tree_exiting.connect(_on_overwrite_answered.bind(false))

	get_parent().add_child(dlg)
	# Set text AFTER add_child so the dialog's labels exist
	dlg.setTitle("Confirm File Replace")
	dlg.setMessage("This folder already contains a file named '%s.%s'.\nWould you like to replace the existing file?" % [fileName, fileType])
	dlg.myWindow.position = myWindow.position + Vector2(40, 40)


func _on_overwrite_answered(accepted : bool) -> void:
	if _answerHandled:
		return
	_answerHandled = true
	_confirming = false
	saveButton.disabled = false
	cancelButton.disabled = false
	if accepted:
		_start_download()
	else:
		_on_cancel_pressed()   # "no" cancels the whole download


func _start_download() -> void:
	_saved = true
	var dl := downloadingScene.instantiate()
	dl.entry = entry
	dl.fileName = fileName
	dl.fileType = fileType
	dl.websiteSource = websiteSource
	dl.filesize_num = filesize_num
	dl.filesize_unit = filesize_unit
	dl.duration = downloadDuration if downloadDuration > 0.0 else _estimate_duration()
	dl.sourceBrowser = sourceBrowser
	
	get_parent().add_child(dl)
	WebDirectory.activeDownload = dl
	dl.myWindow.position = myWindow.position + Vector2(24, 24)
	queue_free()

func _on_browser_closed() -> void:
	if _confirmDlg:
		_answerHandled = true       # stop the confirm's tree_exiting from re-running the "No" path
		_confirmDlg.queue_free()
	_on_cancel_pressed()

func _on_close_button_button_up() -> void:
	_on_cancel_pressed()
