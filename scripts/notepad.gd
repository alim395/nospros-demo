extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
@export var textPanel : TextEdit
var isMinimize : bool = false

# Title Bar Buttons
var fileButton : MenuButton
var formatButton : MenuButton

# Status Bar Labels
@export var LineNum : Label
@export var ColNum : Label
@export var CharCount : Label

# File properties
var fileName : String = "Untitled"
var isSaved : bool = false
var textChanged : bool = false

# Custom Signals
signal newNote
signal closeNote
signal saveNote
signal openNote

# Dialogs
var openSubMenu : PopupMenu

@onready var YNDialog = preload("res://scenes/YNWindow.tscn")
@onready var FormDialog = preload("res://scenes/FormWindow.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	theme = globalParameters.defaultWindowTheme
	
	# Button Menu Functions
	fileButton = $Window/Panel/VContainer/TitleBarContainer/File
	var filePopup : PopupMenu = fileButton.get_popup()
	filePopup.clear()
	filePopup.add_item("New", 0)
	# Open Sub Menu
	filePopup.add_submenu_node_item("Open...",openSubMenu,5)
	filePopup.add_item("Save", 1)
	filePopup.add_item("Save as...", 2)
	filePopup.add_separator("",3)
	filePopup.add_item("Exit", 4)
	filePopup.id_pressed.connect(fileMenu)
	
	formatButton = $Window/Panel/VContainer/TitleBarContainer/Format
	formatButton.get_popup().id_pressed.connect(formatMenu)

func setFileName(fName : String) -> void:
	myWindow.title = fName + " - Notepad"
	fileName = fName

func getFileName() -> String:
	return fileName

func setTextStatic(msg : String) -> void:
	textPanel.editable = true
	textPanel.text = msg
	textPanel.editable = false
	updateStatusBar()

func setTextFree(msg : String) -> void:
	textPanel.editable = true
	textPanel.text = msg
	updateStatusBar()

func getText() -> String:
	return textPanel.text

func openWindow() -> void:
	myWindow.visible = true

func setTaskButton(tB : taskbarButton) -> void:
	myTaskButton = tB
	myTaskButton.pressed.connect(minimizeWindow)

func minimizeWindow() -> void:
	isMinimize = true
	myWindow.visible = not isMinimize
	if myTaskButton.button_pressed:
		isMinimize = false
		myWindow.visible = not isMinimize
		myWindow.grab_focus()

func _on_window_close_requested() -> void:
	#globalParameters.closeApp(myTaskButton.taskName)
	closeNote.emit(fileName)
	myTaskButton.queue_free()
	queue_free()

func _on_theme_changed() -> void:
	myWindow.theme = theme

func updateStatusBar() -> void:
	var lineInt : int = textPanel.get_caret_line() + 1
	var colInt : int = textPanel.get_caret_column() + 1
	var charCountInt : int = 0
	
	if textPanel.get_selected_text().length() > 0:
		charCountInt = textPanel.get_selected_text().length()
	else:
		charCountInt = textPanel.text.length()
	
	# Format String
	LineNum.text = "Ln " + str(lineInt)
	ColNum.text = "Col " + str(colInt)
	CharCount.text = str(charCountInt) + " Characters"

func _on_text_edit_caret_changed() -> void:
	updateStatusBar()

func fileMenu(id : int) -> void:
	match id:
		0:
			print("NEW FILE")
			if not isSaved:
				_on_window_close_requested()
			newNote.emit()
		1:
			print("SAVE")
			if isSaved:
				saveNote.emit(fileName, textPanel.text)
			else:
				# Save As...
				saveNotepadAs()
		2:
			print("SAVE AS...")
			saveNotepadAs()
		4:
			print("EXIT")
			if isSaved and textChanged:
				saveNotepad(true)
			else:
				_on_window_close_requested()
		_:
			print(id)

func formatMenu(id : int) -> void:
	match id:
		0:
			formatButton.get_popup().toggle_item_checked(0)
			_on_word_wrap_toggle()
		_:
			print(id)

func _on_word_wrap_toggle() -> void:
	if textPanel.wrap_mode == TextEdit.LINE_WRAPPING_BOUNDARY:
		textPanel.wrap_mode = TextEdit.LINE_WRAPPING_NONE
	else:
		textPanel.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY

func saveNotepad(isExit : bool = false) -> void:
	var yn = YNDialog.instantiate()
	yn.setMessage("Do you want to save changes to " + fileName + ".txt?")
	yn.yesPress.connect(yesSaveNotepad.bind(isExit))
	yn.noPress.connect(cancelSaveNotepad.bind(isExit))
	add_child(yn)

func yesSaveNotepad(isExit : bool = false) -> void:
	saveNote.emit(fileName, textPanel.text)
	if isExit:
		_on_window_close_requested()

func saveNotepadAs(isExit : bool = false) -> void:
	var yn = YNDialog.instantiate()
	yn.setMessage("Do you want to save this file?")
	yn.yesPress.connect(yesSaveNotepadAs.bind(isExit))
	yn.noPress.connect(cancelSaveNotepad.bind(isExit))
	add_child(yn)

func yesSaveNotepadAs(isExit : bool = false) -> void:
	var fD = FormDialog.instantiate()
	add_child(fD)
	fD.savePress.connect(confirmSaveNotepadAs.bind(isExit))
	fD.cancelPress.connect(cancelSaveNotepad.bind(isExit))

func confirmSaveNotepadAs(fName : String, isExit : bool = false) -> void:
	setFileName(fName)
	myTaskButton.set_task(fName + " - Notepad")
	yesSaveNotepad(isExit)

func cancelSaveNotepad(isExit) -> void:
	if isExit:
		_on_window_close_requested()

func _on_text_edit_text_changed() -> void:
	textChanged = true

func updateSubMenu(savedNotes : Array[notepadInstance]) -> void:
	if openSubMenu == null:
		openSubMenu = PopupMenu.new()
	openSubMenu.clear()
	var i = 0
	for n in savedNotes:
		openSubMenu.add_item(n.fileName, i)
		i += 1
	if not openSubMenu.id_pressed.is_connected(openMenu):
		openSubMenu.id_pressed.connect(openMenu)

func openMenu(id : int) -> void:
	var fName  = openSubMenu.get_item_text(id)
	openNote.emit(fName)
