extends customWindow

#@export var myTaskButton : taskbarButton
@export var webPage : WebPage
@export var addressBar : LineEdit
@export var progressBar : ProgressBar
@export var bodyContainer : PanelContainer

@export var nextButton : Button
@export var prevButton : Button
@export var nextNavButton : MenuButton
@export var prevNavButton : MenuButton
#@export var menu_offset : Vector2i = Vector2i(-40,0)

var defaultScene : PackedScene
var currentScene : PackedScene
var currentSceneName : String = "Untitled"

var nextScene : PackedScene = null
var prevScene : PackedScene = null

var webHistoryQueue : Array[String]
var currentQPos : int = -1
enum Nav { NEW, TRAVERSE, REFRESH }

var isMinimize : bool = false

# Downloads
@export var downloadScene : PackedScene
@export var errorScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if not webPage:
		webPage = $WindowContainer/Layout/PanelMargin/Panel/VContainer/BodyContainer/webPage
	if not addressBar:
		addressBar = $WindowContainer/Layout/PanelMargin/Panel/VContainer/AddressBarPanel3/BarMargin/AddressBarContainer/AddressInput
	if not progressBar:
		progressBar = $WindowContainer/Layout/PanelMargin/Panel/VContainer/StatusBarPanel/HBoxContainer/ProgressPadding/MarginContainer/ProgressBar
	if not bodyContainer:
		bodyContainer = $WindowContainer/Layout/PanelMargin/Panel/VContainer/BodyContainer
	defaultScene = WebDirectory.webDictionary["Example"]
	changeWebPage(defaultScene)
	
	updateProgramIcon()
	
	prevNavButton.get_popup().about_to_popup.connect(populateBackMenu)
	nextNavButton.get_popup().about_to_popup.connect(populateForwardMenu)
	prevNavButton.get_popup().id_pressed.connect(goToHistoryIndex)
	nextNavButton.get_popup().id_pressed.connect(goToHistoryIndex)
	#print_tree_pretty()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("DEBUG_404"):
		error404()
	## TEST DOWNLOAD
	#if event.is_action_pressed("DEBUG_Download"):
		#print("requesting download:")
		#requestDownload("TEST DOWNLOAD")

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func openWindow() -> void:
	myWindow.visible = true
	_on_window_container_focus_entered()

func _on_close_button_button_up() -> void:
	super._on_close_button_button_up()
	closeWindow()

func closeWindow() -> void:
	myWindow.visible = false
	if myTaskButton:
		myTaskButton.close_task()
	queue_free()

func _on_minimize_button_button_up() -> void:
	super._on_minimize_button_button_up()
	if myTaskButton:
		myTaskButton.button_pressed = false

func minimizeWindow() -> void:
	if myTaskButton:
		isMinimize = true
		myWindow.visible = not isMinimize
		if myTaskButton.button_pressed:
			isMinimize = false
			myWindow.visible = not isMinimize
			myWindow.grab_focus()

func updateProgramIcon() -> void:
	setProgamIcon(globalParameters.icon_dict.get("Browser"))

func updateProgressBar() -> void:
	progressBar.value = webPage.getProgressPercent() * 100
	progressBar.visible = (progressBar.value < progressBar.max_value)

func changeWebPage(page : PackedScene, nav : Nav = Nav.NEW, targetIndex : int = -1) -> void:
	webPage.queue_free()
	webPage = page.instantiate()
	bodyContainer.add_child(webPage)
	currentSceneName = webPage.websiteName
	addressBar.text = webPage.address
	setTitle(currentSceneName + " - GlobeTrotter")
	if webPage.skip:
		updateProgressBar()
	else:
		webPage.item_loaded.connect(updateProgressBar)
		webPage.load_finished.connect(updateProgressBar)

	currentScene = page
	webPage.requestPage.connect(request)
	webPage.requestDownload.connect(requestDownload)

	# Update Web History
	updateWebHistory(webPage.websiteName, nav, targetIndex)

func updateWebHistory(pageName : String, nav : Nav = Nav.NEW, targetIndex : int = -1) -> void:
	match nav:
		Nav.NEW:
			if webHistoryQueue.is_empty():
				webHistoryQueue.append(pageName)
				currentQPos = 0
			elif webHistoryQueue[currentQPos] != pageName:
				webHistoryQueue = webHistoryQueue.slice(0, currentQPos + 1)
				webHistoryQueue.append(pageName)
				currentQPos = webHistoryQueue.size() - 1
		Nav.TRAVERSE:
			currentQPos = targetIndex
		Nav.REFRESH:
			pass

	currentQPos = clampi(currentQPos, 0, maxi(webHistoryQueue.size() - 1, 0))

	# Update Next and Prev
	if currentQPos > 0:
		prevScene = WebDirectory.webDictionary.get(webHistoryQueue[currentQPos - 1])
	else:
		prevScene = null
	if currentQPos < webHistoryQueue.size() - 1:
		nextScene = WebDirectory.webDictionary.get(webHistoryQueue[currentQPos + 1])
	else:
		nextScene = null

	print(currentQPos)

	nextButton.disabled = not nextScene
	nextButton.flat = not nextScene
	nextNavButton.disabled = nextButton.disabled
	nextNavButton.flat = nextButton.flat
	prevButton.disabled = not prevScene
	prevButton.flat = not prevScene
	prevNavButton.disabled = prevButton.disabled
	prevNavButton.flat = prevButton.flat

	print(webHistoryQueue)

func _on_home_button_up() -> void:
	changeWebPage(defaultScene, Nav.NEW)

func _on_refresh_button_up() -> void:
	changeWebPage(currentScene, Nav.REFRESH)

func request(pageName) -> void:
	if WebDirectory.webDictionary.has(pageName):
		print("FOUND " + pageName)
		changeWebPage(WebDirectory.webDictionary.get(pageName))
	else:
		print("PAGE NOT FOUND")
		error404()

func requestDownload(key : String) -> void:
	var entry : DownloadEntry = WebDirectory.getDownload(key)
	if entry == null:
		print("DOWNLOAD NOT FOUND: ", key)
		error404()
		return
	if WebDirectory.isDownloadBusy():
		showError("A download is already in progress.\nPlease wait for it to finish before starting another.")
		return

	var dlg := downloadScene.instantiate()
	dlg.sourceBrowser = self
	dlg.applyEntry(entry)
	WebDirectory.activeDownload = dlg
	get_parent().add_child(dlg)
	dlg.myWindow.position = myWindow.position + Vector2(40, 40)

func error404() -> void:
	changeWebPage(WebDirectory.webDictionary.get("error404"))

func goToHistoryIndex(index : int) -> void:
	if index < 0 or index >= webHistoryQueue.size() or index == currentQPos:
		return
	var scene : PackedScene = WebDirectory.webDictionary.get(webHistoryQueue[index])
	if scene == null:
		push_error("No scene registered for: " + webHistoryQueue[index])
		return
	changeWebPage(scene, Nav.TRAVERSE, index)

func _on_back_button_up() -> void:
	goToHistoryIndex(currentQPos - 1)

func _on_forward_button_up() -> void:
	goToHistoryIndex(currentQPos + 1)

func populateBackMenu() -> void:
	var popup := prevNavButton.get_popup()
	popup.clear()
	for i in range(currentQPos - 1, -1, -1): # nearest first
		popup.add_item(webHistoryQueue[i], i)
	popup.position = Vector2i(prevNavButton.global_position) + Vector2i(-58,34)

func populateForwardMenu() -> void:
	var popup := nextNavButton.get_popup()
	popup.clear()
	for i in range(currentQPos + 1, webHistoryQueue.size()): # nearest first
		popup.add_item(webHistoryQueue[i], i)
	popup.position = Vector2i(nextNavButton.global_position) + Vector2i(-26,34)

func _on_stop_pressed() -> void:
	webPage.stopLoad()

func _on_go_pressed() -> void:
	var pageName : String = WebDirectory.getPageName(addressBar.text)
	if pageName == "":
		error404()
	else:
		request(pageName)

func _on_address_input_text_submitted(new_text: String) -> void:
	if new_text:
		print("Going to: ", new_text)
		_on_go_pressed()

func showError(msg : String) -> void:
	if not errorScene:
		push_error("customBrowser: errorScene is not assigned")
		return
	var err := errorScene.instantiate()
	err.setErrorType(globalParameters.errorType.critical)
	err.setErrorMessage(msg)
	get_parent().dWins.add_child(err)
