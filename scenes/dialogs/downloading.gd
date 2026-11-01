extends customWindow

## Emitted when the fake download reaches 100%
signal download_finished
## Emitted if the user cancels mid-download
signal download_cancelled
## Emitted when the user presses Open after the download finishes
signal open_requested

const UNIT_NAMES : Array[String] = ["Bytes", "KB", "MB", "GB"]

## Duration of Download (seconds)
@export var duration : float = 5.0
## Downloading Filename
@export var fileName : String = "Untitled"
## Downloading Filetype
@export var fileType : String = "txt"
## Downloading Filesize Number (in filesize_unit)
@export var filesize_num : float = 456.0
## Unit that filesize_num is expressed in
@export var filesize_unit : globalParameters.filesize_unit = globalParameters.filesize_unit.Bytes
## Downloading File Source
@export var websiteSource : String = "example.com"
## Where the file is "saved" (shown in the dialog)
@export var saveLocation : String = "C:\\Documents and Settings\\User\\Desktop"
## Start downloading automatically when the dialog opens
@export var autoStart : bool = true

@export_group("Speed Variation")
## How often (per segment) the connection stalls almost completely
@export_range(0.0, 0.5) var stallChance : float = 0.08
## How often a segment is a fast burst
@export_range(0.0, 0.5) var burstChance : float = 0.12
## Shortest / longest speed segment (seconds). Use longer values for long downloads
@export var segmentLenMin : float = 0.15
@export var segmentLenMax : float = 0.6
## How often the stats text refreshes (seconds)
@export var statsInterval : float = 0.5
@export_group("")

## Progress
var current : float = 0.0      # bytes downloaded so far
var progPercent : float = 0.0  # 0.0 - 1.0
var elapsed : float = 0.0
var downloading : bool = false
var finished : bool = false

# Speed profile
var _segT : Array[float] = []   # segment boundary times
var _segP : Array[float] = []   # cumulative progress (0-1) at each boundary
var _segI : int = 0
var _smoothedRate : float = 0.0  # bytes per second
var _statsTimer : float = 0.0

# Nodes (auto-found by name if left unassigned)
@export var initLabel : Label
@export var progressBar : Range            # ProgressBar / TextureProgressBar
@export var descLabel : Label
@export var closeCheck : CheckBox
@export var openButton : Button
@export var cancelButton : Button
@export var downloadAnimation : Node       # anything with play()/stop()

var entry : DownloadEntry
var sourceBrowser : Node

func _ready() -> void:
	super._ready()
	_resolve_nodes()
	if openButton:
		openButton.pressed.connect(_on_open_pressed)
	if cancelButton:
		cancelButton.pressed.connect(_on_cancel_pressed)
	initFile()
	if autoStart:
		startDownload()
	if sourceBrowser:
		sourceBrowser.tree_exiting.connect(_on_browser_closed)


func _process(delta: float) -> void:
	if not downloading:
		return
	elapsed += delta
	var prev : float = current
	updateProgress(_progressAt(elapsed))

	# Smooth the displayed rate so it doesn't flicker every frame
	var instant : float = (current - prev) / maxf(delta, 0.0001)
	_smoothedRate = lerpf(_smoothedRate, instant, 1.0 - exp(-delta * 3.0))

	# Refresh the stats text only every so often
	_statsTimer += delta
	if _statsTimer >= statsInterval:
		_statsTimer = 0.0
		_refresh_stats()

	if elapsed >= duration:
		finishDownload()


func _resolve_nodes() -> void:
	if not initLabel: initLabel = find_child("InitLabel", true, false) as Label
	if not progressBar: progressBar = find_child("Progress", true, false) as Range
	if not descLabel: descLabel = find_child("DescLabel", true, false) as Label
	if not closeCheck: closeCheck = find_child("CloseCheck", true, false) as CheckBox
	if not openButton: openButton = find_child("Open", true, false) as Button
	if not cancelButton: cancelButton = find_child("Cancel", true, false) as Button
	if not downloadAnimation: downloadAnimation = find_child("DownloadAnimation", true, false)
	if not progressBar:
		push_warning("Progress node not found or not a Range")


func initFile() -> void:
	if initLabel:
		initLabel.text = "Saving:\n%s.%s from %s" % [fileName, fileType, websiteSource]
	if progressBar:
		progressBar.min_value = 0.0
		progressBar.max_value = 100.0
		progressBar.value = 0.0
	if openButton:
		openButton.disabled = true
	if cancelButton:
		cancelButton.text = "Cancel"
	_refresh_title()
	_refresh_stats()


func initProgress() -> void:
	current = 0.0
	progPercent = 0.0
	elapsed = 0.0
	finished = false
	_smoothedRate = 0.0
	_statsTimer = 0.0
	_buildProfile()
	if progressBar:
		progressBar.value = 0.0
	_refresh_title()
	_refresh_stats()


func startDownload() -> void:
	initProgress()
	downloading = true
	_set_animation(true)


## Takes a 0-1 fraction; `current` is derived from it in bytes
func updateProgress(fraction : float = 0.0) -> void:
	progPercent = clampf(fraction, 0.0, 1.0)
	current = _total_bytes() * progPercent
	if progressBar:
		progressBar.value = progPercent * 100.0
	_refresh_title()


func finishDownload() -> void:
	downloading = false
	finished = true
	WebDirectory.releaseDownload(self)
	updateProgress(1.0)
	_refresh_stats()
	_set_animation(false)
	if openButton:
		openButton.disabled = false
	if cancelButton:
		cancelButton.text = "Close"
	WebDirectory.deliverDownload(entry)
	download_finished.emit()
	MusicManager.sfx_player.play_SFX_from_library_poly("notify")
	if closeCheck and closeCheck.button_pressed:
		_close_window()


func cancelDownload() -> void:
	downloading = false
	WebDirectory.releaseDownload(self)
	_set_animation(false)
	download_cancelled.emit()
	_close_window()


# --- Speed profile ---

func _buildProfile() -> void:
	_segT = [0.0]
	_segP = [0.0]
	_segI = 0
	var weights : Array[float] = []
	var t : float = 0.0
	var total : float = 0.0
	while t < duration:
		var segLen : float = minf(randf_range(segmentLenMin, segmentLenMax), duration - t)
		var isEdge : bool = t == 0.0 or t + segLen >= duration  # no stalls at very start/end
		var speed : float = randf_range(0.4, 1.6)
		var roll : float = randf()
		if not isEdge and roll < stallChance:
			speed = randf_range(0.0, 0.08)
		elif roll > 1.0 - burstChance:
			speed = randf_range(2.0, 3.5)
		t += segLen
		var amount : float = speed * segLen
		weights.append(amount)
		total += amount
		_segT.append(t)
	# Normalize so the curve ends at exactly 100% at `duration`
	var cum : float = 0.0
	for w in weights:
		cum += w / maxf(total, 0.0001)
		_segP.append(cum)
	_segP[_segP.size() - 1] = 1.0


func _progressAt(time : float) -> float:
	if duration <= 0.0 or time >= duration or _segT.size() < 2:
		return 1.0
	while _segI < _segT.size() - 2 and time >= _segT[_segI + 1]:
		_segI += 1
	var t0 : float = _segT[_segI]
	var t1 : float = _segT[_segI + 1]
	var f : float = clampf((time - t0) / maxf(t1 - t0, 0.0001), 0.0, 1.0)
	return lerpf(_segP[_segI], _segP[_segI + 1], f)


# --- Buttons ---

func _on_cancel_pressed() -> void:
	if finished:
		_close_window()   # button reads "Close" after completion
	else:
		cancelDownload()


func _on_open_pressed() -> void:
	if finished:
		WebDirectory.openDownload(entry)
		open_requested.emit()
		_close_window() 


# --- Units / display ---

func _total_bytes() -> float:
	# Explicit match so it doesn't depend on the enum's order
	var mult : float = 1.0
	match filesize_unit:
		globalParameters.filesize_unit.Bytes: mult = 1.0
		globalParameters.filesize_unit.KB: mult = 1024.0
		globalParameters.filesize_unit.MB: mult = 1048576.0
		globalParameters.filesize_unit.GB: mult = 1073741824.0
	return maxf(filesize_num * mult, 1.0)


func _unit_index_for(bytes : float) -> int:
	var i : int = 0
	while bytes >= 1024.0 and i < UNIT_NAMES.size() - 1:
		bytes /= 1024.0
		i += 1
	return i


func _fmt_in_unit(bytes : float, unitIdx : int) -> String:
	var v : float = bytes / pow(1024.0, unitIdx)
	return str(int(v)) if unitIdx == 0 else "%.1f" % v


func _refresh_title() -> void:
	setTitle("%d%% of %s.%s Completed" % [int(progPercent * 100.0), fileName, fileType])


func _refresh_stats() -> void:
	if not descLabel:
		return
	var total : float = _total_bytes()
	var unitIdx : int = _unit_index_for(total)          # copied/total share one unit
	var rateIdx : int = _unit_index_for(_smoothedRate)  # rate picks its own

	# Time left is based on the average rate so far, like real downloaders
	var avgRate : float = current / elapsed if elapsed > 0.0 else 0.0
	var left : int = 0
	if finished:
		left = 0
	elif avgRate > 0.0:
		left = ceili((total - current) / avgRate)
	else:
		left = ceili(duration)

	descLabel.text = "Estimated time left:  %d sec (%s %s of %s %s copied)\nDownload to:  %s\nTransfer rate:  %s %s/Sec" % [
		left,
		_fmt_in_unit(current, unitIdx), UNIT_NAMES[unitIdx],
		_fmt_in_unit(total, unitIdx), UNIT_NAMES[unitIdx],
		saveLocation,
		_fmt_in_unit(_smoothedRate, rateIdx), UNIT_NAMES[rateIdx]]

func _set_animation(on : bool) -> void:
	if not downloadAnimation:
		return
	if on and downloadAnimation.has_method("play"):
		downloadAnimation.play()
	elif not on and downloadAnimation.has_method("stop"):
		downloadAnimation.stop()

func _on_browser_closed() -> void:
	if downloading:
		cancelDownload()
	else:
		_close_window()

func _on_close_button_button_up() -> void:
	_on_cancel_pressed()

func _close_window() -> void:
	super._on_close_button_button_up()
	queue_free()
