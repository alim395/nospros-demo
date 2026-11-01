extends Panel
class_name WebPage

@export var backgroundColor : Color = Color.WHITE
@export var websiteName : String = "exampleName"
@export var address : String = "http://www.example.com/index.php"
## Delay before content begins loading in seconds.
@export var initDelay : float = 0.4
@export var imageDelay : float = 0.33
@export var defaultTheme : Theme
@export var skip : bool = false

# Content
var contentContainer : BoxContainer
var webTexts : Array[RichTextLabel]
var webImages : Array[TextureRect]
var numContent : int = 0
var progress : int = 0

var isLoading : bool = true
signal item_loaded
signal load_finished

signal requestPage(pageName)
signal requestDownload(downloadKey)

const DOWNLOAD_PREFIX : String = "download:"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Apply theme if no parents
	if not self.get_parent().get_parent():
		theme = defaultTheme
	else:
		theme = null
	
	# Set Background Color
	var styleBox: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	styleBox.set("bg_color", backgroundColor)
	add_theme_stylebox_override("panel", styleBox)
	
	# Get Content
	contentContainer = $ScrollContainer/MarginContainer/webPageContainer
	#contentContainer.print_tree_pretty()
	for c in contentContainer.get_children():
		c.visible = false
		numContent+=1
		if c is RichTextLabel:
			webTexts.append(c)
		elif c is TextureRect:
			webImages.append(c)
	#print(webTexts)
	#print(webImages)
	
	loadContent()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if progress < numContent:
		isLoading = true
	else:
		isLoading = false

func loadContent() -> void:
	print("Loading Content...")
	#if not skip:
	await get_tree().create_timer(initDelay).timeout # Initial Delay
	for t in webTexts:
		t.visible = true
		incrementProgress()
	if not skip:
		await get_tree().create_timer(initDelay).timeout # Delay for Images
	for i in webImages:
		i.visible = true
		if skip:
			i.skip_load()
			incrementProgress()
		else:
			i.start_load()
		i.load_finished.connect(incrementProgress)

func stopLoad() -> void:
	for i in webImages:
		if i.is_loading():
			var imageError:ImageError = WebDirectory.imageError.instantiate()
			imageError.setText(i.altText)
			imageError.setSize(i.size.x,i.size.y)
			i.replace_by(imageError)
			i.queue_free()
			incrementProgress()
	webImages.clear()

func incrementProgress(i : int = 1):
	progress += i
	if progress >= numContent:
		print("All content Loaded!")
		load_finished.emit()
	else:
		item_loaded.emit()

func getProgressPercent() -> float:
	if (not isLoading) or skip:
		return 100.0
	else:
		if progress == 0.0:
			return 0.0
		#print(float(progress)/numContent)
		return float(progress)/numContent

func _on_body_text_meta_clicked(meta: Variant) -> void:
	var target : String = str(meta)
	print("Link clicked: ", target)
	if target.begins_with(DOWNLOAD_PREFIX):
		requestDownload.emit(target.trim_prefix(DOWNLOAD_PREFIX))
	else:
		requestPage.emit(target)
