extends Node

var examplePage : PackedScene
var error404 : PackedScene
var imageError : PackedScene

var webDictionary : Dictionary[String,PackedScene]
var webAddressBook : Dictionary[String, String]
var downloadDictionary : Dictionary[String, DownloadEntry]

const DEFAULT_DOCUMENTS : Array[String] = [
	"index.php", "index.html", "index.htm",
	"default.asp", "default.aspx", "default.htm",
]

var AppManager : Node
var testNote : notepadInstance = notepadInstance.new("TEST DOWNLOAD", "TESTING TESTING 123!")

var activeDownload : Node = null

func _ready() -> void:
	examplePage = preload("res://scenes/webPages/exampleWebPage.tscn")
	error404 = preload("res://scenes/webPages/error404.tscn")
	imageError = preload("res://scenes/webPages/imageError.tscn")

	createWebDictionary()
	createDownloadDictionary()

func createWebDictionary() -> void:
	if examplePage:
		insertWebPage(examplePage)
	if error404:
		insertWebPage(error404)

	print(webDictionary.keys())

func insertWebPage(p : PackedScene) -> void:
	var sceneState : SceneState = p.get_state()
	var pageName : String = ""
	var pageAddress : String = ""

	# Collect both values first, so property order in the scene doesn't matter
	for i in range(0, sceneState.get_node_property_count(0)):
		var propName : String = sceneState.get_node_property_name(0, i)
		if propName == "websiteName":
			pageName = sceneState.get_node_property_value(0, i)
		elif propName == "address":
			pageAddress = sceneState.get_node_property_value(0, i)

	if pageName == "":
		push_warning("Web page has no websiteName, skipping: " + p.resource_path)
		return
	webDictionary[pageName] = p

	var key : String = normalizeAddress(pageAddress)
	if key == "":
		push_warning("Web page '%s' has no address, so it can't be reached from the address bar." % pageName)
		return
	if webAddressBook.has(key) and webAddressBook[key] != pageName:
		push_warning("Address collision on '%s': '%s' is overwriting '%s'." % [key, pageName, webAddressBook[key]])
	webAddressBook[key] = pageName

func normalizeAddress(address : String) -> String:
	var a : String = address.strip_edges().to_lower()
	a = a.trim_prefix("https://").trim_prefix("http://")
	a = a.trim_prefix("www.")
	a = a.get_slice("#", 0).get_slice("?", 0)
	a = a.rstrip("/")
	for doc in DEFAULT_DOCUMENTS:
		if a.ends_with("/" + doc):
			a = a.trim_suffix("/" + doc).rstrip("/")
			break
	return a

func getPageName(address : String) -> String:
	return webAddressBook.get(normalizeAddress(address), "")

func createDownloadDictionary() -> void:
	var entry := DownloadEntry.new()
	entry.fileName = "TEST DOWNLOAD"
	entry.fileType = "txt"
	entry.fileTypeLong = "Text Document"
	entry.filesize_num = 456.0
	entry.filesize_unit = globalParameters.filesize_unit.Bytes
	entry.websiteSource = "example.com"
	entry.payload = testNote
	insertDownload(entry)

func insertDownload(d : DownloadEntry) -> void:
	if d == null or d.fileName == "":
		push_warning("Download entry is missing a fileName, skipping")
		return
	downloadDictionary[d.fileName] = d

func getDownload(key : String) -> DownloadEntry:
	return downloadDictionary.get(key)

## Called when the fake download completes ("save" step)
func deliverDownload(d : DownloadEntry) -> void:
	if d == null:
		push_error("deliverDownload: entry is null")
		return
	print("deliverDownload: ", d.fileName, ".", d.fileType)
	match d.fileType.to_lower():
		"txt":
			_deliver_text(d)
		_:
			push_warning("No deliver handler for filetype: " + d.fileType)

## Called when the user presses Open in the finished dialog
func openDownload(d : DownloadEntry) -> void:
	if d == null:
		push_error("openDownload: entry is null")
		return
	print("openDownload: ", d.fileName, ".", d.fileType)
	match d.fileType.to_lower():
		"txt":
			_open_text(d)
		_:
			push_warning("No open handler for filetype: " + d.fileType)


# --- Text files (notepadInstance payload) ---

func _deliver_text(d : DownloadEntry) -> void:
	if not d.payload is notepadInstance:
		push_error("Payload for '%s' is not a notepadInstance" % d.fileName)
		return
	var note : notepadInstance = d.payload
	AppManager.NotepadWins.saveNotepad(note.getName(), note.getText())

func _open_text(d : DownloadEntry) -> void:
	if not d.payload is notepadInstance:
		push_error("Payload for '%s' is not a notepadInstance" % d.fileName)
		return
	var note : notepadInstance = d.payload
	var wins = AppManager.NotepadWins
	# Safety net: make sure it's saved even if deliver didn't run
	if wins.getSavedNotepad(note.getName()) == null:
		wins.saveNotepad(note.getName(), note.getText())
	wins.openNotepad(note.getName())

func downloadExists(d : DownloadEntry) -> bool:
	if d == null:
		return false
	match d.fileType.to_lower():
		"txt":
			if d.payload is notepadInstance:
				var note : notepadInstance = d.payload
				return AppManager.NotepadWins.getSavedNotepad(note.getName()) != null
	return false

func isDownloadBusy() -> bool:
	return is_instance_valid(activeDownload) and not activeDownload.is_queued_for_deletion()

func releaseDownload(who : Node) -> void:
	if activeDownload == who:
		activeDownload = null
