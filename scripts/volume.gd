extends Control

@export var myWindow : Window
@export var myTaskButton : taskbarButton
var isMinimize : bool = false

@export var masterBalance : HSlider
@export var masterVol : VSlider

@export var musicBalance : HSlider
@export var musicVol : VSlider

@export var sfxBalance : HSlider
@export var sfxVol : VSlider

@export var masterMute : CheckBox
@export var musicMute : CheckBox
@export var sfxMute : CheckBox

# Test Vars
@export var testMaster : AudioStreamPlayer
@export var testMusic : AudioStreamPlayer
@export var testSFX : AudioStreamPlayer

@export var audioDeviceLabel : Label

var masterPanner : AudioEffectPanner
var musicPanner : AudioEffectPanner
var sfxPanner : AudioEffectPanner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init Sliders	
	masterPanner = AudioServer.get_bus_effect(0, 0)
	masterBalance.value = masterPanner.get_pan()
	masterVol.value = AudioServer.get_bus_volume_linear(0)
	masterMute.button_pressed = AudioServer.is_bus_mute(0)
	
	musicPanner = AudioServer.get_bus_effect(1, 0)
	musicBalance.value = musicPanner.get_pan()
	musicVol.value = AudioServer.get_bus_volume_linear(1)
	musicMute.button_pressed = AudioServer.is_bus_mute(1)
	
	sfxPanner = AudioServer.get_bus_effect(2, 0)
	sfxBalance.value = sfxPanner.get_pan()
	sfxVol.value = AudioServer.get_bus_volume_linear(2)
	sfxMute.button_pressed = AudioServer.is_bus_mute(2)
	
	audioDeviceLabel.text = AudioServer.get_output_device()
	
	#if musicButton != null:
		#musicButton.pressed.connect(playMusic)
	#if sfxButton != null:
		#sfxButton.pressed.connect(playSFX)

func _on_bal_slider_value_changed(value: float) -> void:
	if masterPanner != null:
		masterPanner.set_pan(value)

func _on_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_mute_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	if musicMute != null:
		musicMute.set_pressed_no_signal(toggled_on)
	if sfxMute != null:
		sfxMute.set_pressed_no_signal(toggled_on)
	
	# If Mute, disable sliders
	masterVol.editable = not toggled_on
	masterBalance.editable = not toggled_on
	musicVol.editable = not toggled_on
	musicBalance.editable = not toggled_on
	sfxVol.editable = not toggled_on
	sfxBalance.editable = not toggled_on

func _on_music_bal_slider_value_changed(value: float) -> void:
	if musicPanner != null:
		musicPanner.set_pan(value)

func _on_music_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sfx_bal_slider_value_changed(value: float) -> void:
	if sfxPanner != null:
		sfxPanner.set_pan(value)

func _on_sfx_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

#func playMusic() -> void:
	#if testMusic != null:
		#testMusic.play()
#
#func playSFX() -> void:
	#if testSFX != null:
		#testSFX.play()

func _on_music_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(1, toggled_on)
	musicVol.editable = not toggled_on
	musicBalance.editable = not toggled_on

func _on_sfx_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(2, toggled_on)
	sfxVol.editable = not toggled_on
	sfxBalance.editable = not toggled_on

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
	myWindow.visible = false
	globalParameters.closeApp(myTaskButton.get_task())
	queue_free()

func _on_vol_slider_drag_ended(_value_changed: bool) -> void:
	testMaster.play()

func _on_music_slider_drag_ended(_value_changed: bool) -> void:
	testMusic.play()

func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	testSFX.play()
