extends Control

var savedNotepadInstances : Array[notepadInstance]
var activeNotepadInstances : Array[notepadInstance]

@onready var notepadApp = preload("res://scenes/customApps/customNotepad.tscn")
@export var taskbar : Control

# README
@export_multiline var readmeText : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# README FILE
	saveNotepad("README", readmeText)

func newNotepad(fName : String = "Untitled", fText : String = "Hello World!", fSave : bool = false) -> Node:
	var tfInstance = notepadApp.instantiate()
	#tfInstance.setFileName(fName)
	#tfInstance.setTextFree(fText)
	if fSave:
		tfInstance.isSaved = true
	add_child(tfInstance)
	tfInstance.setFileName(fName)
	tfInstance.setTextFree(fText)
	if get_child_count() > 0:
		tfInstance.myWindow.position += Vector2(randi_range(10,20), randi_range(10,20))
	
	# Notepad Instance
	var nI = notepadInstance.new()
	if fName != null:
		nI.setName(fName)
	if fText != null:
		nI.setText(fText)
	activeNotepadInstances.push_back(nI)
	
	# Open Task
	if fName != null:
		var taskName = fName + " - Notepad"
		var tB = taskbar.openTask(taskName)
		tfInstance.setTaskButton(tB)
	else:
		var tB = taskbar.openTask("Untitled - Notepad")
		tfInstance.setTaskButton(tB)
	return tfInstance

func getSavedNotepad(fName : String) -> notepadInstance:
	for N in savedNotepadInstances:
		if N.getName() == fName:
			return N
	return null

func getActiveNotepad(fName : String) -> notepadInstance:
	updateActiveInstances()
	for N in activeNotepadInstances:
		if N.getName() == fName:
			return N
	return null

func openNotepad(fName) -> void:
	# Check if Already Active
	var nI = getActiveNotepad(fName)
	if nI != null:
		return
	# Check if it exists as saved document
	nI = getSavedNotepad(fName)
	if nI != null:
		newNotepad(nI.getName(), nI.getText(), true)

func saveNotepad(fName : String, fText : String) -> void:
	var nI = getSavedNotepad(fName)
	if nI != null:
		nI.setText(fText)
		print("OVERWRITING TEXT")
	else:
		print("NEW TEXT")
		nI = notepadInstance.new(fName,fText)
		savedNotepadInstances.push_back(nI)
		# Update Open
		if get_children():
			for n in get_children():
				n.updateSubMenu(savedNotepadInstances)
				n.isSaved = true
	updateActiveInstances()

func closeNotepad(fName : String) -> void:
	print("CLOSING " + fName)
	var index = 0
	for N in activeNotepadInstances:
		if N.getName() == fName:
			activeNotepadInstances.pop_at(index)
		index += 1
	updateActiveInstances()

func _on_child_entered_tree(node: Node) -> void:
	node.newNote.connect(newNotepad)
	node.saveNote.connect(saveNotepad)
	node.closeNote.connect(closeNotepad)
	node.openNote.connect(openNotepad)
	node.updateSubMenu(savedNotepadInstances)

func closeAllNotepads() -> void:
	if get_children():
		for n in get_children():
			n.closeWindow()

func updateActiveInstances() -> void:
	if not activeNotepadInstances.is_empty():
		# Get list of Active Instance Names
		var niNames : Array[String]
		for nI in activeNotepadInstances:
			niNames.push_back(nI.fileName)
		# Get List of Active Notepad Names
		var fNames : Array[String]
		if get_children():
			for n in get_children():
				fNames.push_back(n.getFileName())
		# Compare List and remove outliers
		var index = 0
		for aN in niNames:
			if fNames.find(aN) == -1:
				activeNotepadInstances.pop_at(index)
			index +=1

func unMinNotepad(fName : String) -> void:
	if get_children():
		for n in get_children():
			if n.getFileName() == fName:
				n.myTaskButton.set_pressed(true)
				n.minimizeWindow()
				break

func updateIcon() -> void:
	if get_children():
		for n in get_children():
			n.updateProgramIcon()
