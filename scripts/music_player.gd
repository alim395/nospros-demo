extends Control

@export var isShuffle := false
@export var isLoop := false
@export var isPaused := false
var isPlaying := false
var isInitial := true
var isSeeking := false
@export var albumList : Array[MusicPlaylist]
var defaultAlbum : MusicPlaylist

var currentAlbum : MusicPlaylist
var currentAlbumNum := 0
var currentTrack : MusicTrack
var currentTrackArtist : String
var currentTrackNum := 0

@export var trackNumLabel : Label
@export var playtimeLabel : Label
@export var albumOption : OptionButton
@export var trackOption : OptionButton
@export var albumArt : TextureRect
@export var defaultAlbumArt : Texture2D
@export var artistLabel : Label
@export var seekSlider : HSlider

@export var loopButton : Button
@export var shuffleButton : Button

@export var playSound : AudioStream
@export var pauseSound : AudioStream
@export var stopSound : AudioStream
@export var changeSound : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Signals
	if !MusicManager.is_connected("all_music_finished", _on_all_music_finished):
		MusicManager.all_music_finished.connect(_on_all_music_finished)
		
	defaultAlbum = albumList[0]
	currentTrackNum = 0
	currentAlbumNum = 0
	currentAlbum = defaultAlbum
	currentTrack = currentAlbum.tracks[0]
	if currentAlbum.art != null:
		albumArt.texture = currentAlbum.art
	setTrackLabel()
	
	for a in albumList:
		albumOption.add_item(a.name)
	albumOption.select(0)
	
	for t in currentAlbum.tracks:
		trackOption.add_item(t.name)
	trackOption.select(0)
	
	currentTrackArtist = currentTrack.artist
	artistLabel.text = currentTrackArtist
	
	seekSlider.editable = false
	seekSlider.max_value = currentTrack.track.get_length()
	
	MusicManager.stop_music.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(isPlaying):
		updateSeekSlider(seekSlider.value)

func setTrackLabel() -> void:
	var trackNumText = "[%02d]" % (currentTrackNum + 1)
	trackNumLabel.text = trackNumText
	pass

func _on_play_button_pressed() -> void:
	if seekSlider.value != 0:
		isInitial = false
	seekSlider.editable = true
	if not isPlaying:
		isPlaying = true
		if not isPaused:
			MusicManager.play_song.emit(currentTrack, false, false, 0)
		else:
			MusicManager.resume_music.emit()
			if(isSeeking):
				MusicManager.current_player.play(seekSlider.value)
				isSeeking = false
			else:
				MusicManager.sfx_player.play_SFX_from_library("mp_Play")
			isPaused = false

func _on_pause_button_pressed() -> void:
	if isPlaying:
		isPlaying = false
		isPaused = true
		MusicManager.pause_music.emit()
		if not isSeeking:
			MusicManager.sfx_player.play_SFX_from_library("mp_Pause")

func _on_stop_button_pressed() -> void:
	isInitial = true
	seekSlider.editable = false
	if isPaused:
		MusicManager.resume_music.emit()
	isPlaying = false
	isPaused = false
	seekSlider.value = 0
	updateTrackTime(0)
	MusicManager.stop_music.emit()
	MusicManager.sfx_player.play_SFX_from_library("mp_Stop")

func _on_track_option_button_item_selected(index: int) -> void:
	seekSlider.editable = true
	currentTrackNum = index
	updateSong()
	MusicManager.sfx_player.play_SFX_from_library("mp_Change")

func _on_album_option_button_item_selected(index: int) -> void:
	currentAlbumNum = index
	updateAlbum()
	currentTrackNum = 0
	updateSong()

func updateAlbum() -> void:
	if(currentAlbumNum < 0):
		currentAlbumNum = 0
	elif (currentAlbumNum >= (albumList.size() - 1)):
		currentAlbumNum = albumList.size() - 1
	
	isPaused = false
	isPlaying = false
	MusicManager.stop_music.emit()
	
	currentAlbum = albumList[currentAlbumNum]
	
	if currentAlbum.art != null:
		albumArt.texture = currentAlbum.art
	else:
		albumArt.texture = defaultAlbumArt
	
	trackOption.clear()
	for t in currentAlbum.tracks:
		trackOption.add_item(t.name)
	trackOption.select(0)

func updateSong() -> void:
	if isPaused:
		MusicManager.resume_music.emit()
	if(currentTrackNum < 0):
		currentTrackNum = 0
	elif (currentTrackNum >= (currentAlbum.tracks.size() - 1)):
		currentTrackNum = currentAlbum.tracks.size() - 1
	isPlaying = false
	MusicManager.stop_music.emit()
	
	currentTrack = currentAlbum.tracks[currentTrackNum]
	seekSlider.max_value = currentTrack.track.get_length()
	setTrackLabel()
	currentTrackArtist = currentTrack.artist
	artistLabel.text = currentTrackArtist
	isPlaying = true
	MusicManager.play_song.emit(currentTrack, false, false, 0)
	
func _on_prev_track_pressed() -> void:
	currentTrackNum -= 1
	updateSong()
	trackOption.select(currentTrackNum)
	MusicManager.sfx_player.play_SFX_from_library("mp_Change")

func _on_next_track_pressed() -> void:
	currentTrackNum += 1
	updateSong()
	trackOption.select(currentTrackNum)
	MusicManager.sfx_player.play_SFX_from_library("mp_Change")

func updateSeekSlider(songSeconds := 0.0) -> void:
	if isSeeking:
		seekSlider.set_value_no_signal(songSeconds)
	else:
		songSeconds = MusicManager.current_player.get_playback_position()
		seekSlider.set_value_no_signal(songSeconds)
	updateTrackTime(songSeconds)
	if(seekSlider.value == seekSlider.max_value or (songSeconds == 0 && !isInitial)):
		print("current song is done")
		isPlaying = false
		MusicManager.all_music_finished.emit()
	if songSeconds > 0:
		isInitial = false

func updateTrackTime(s : int) -> void:
	var seconds = s % 60
	var minutes = int(s/60)
	
	var playTimetext = "%02d:%02d" % [minutes, seconds]
	playtimeLabel.text = playTimetext

func _on_window_close_requested() -> void:
	#MusicManager.stop_music.emit()
	queue_free()

func _on_tree_exiting() -> void:
	MusicManager.stop_music.emit()

func _on_all_music_finished() -> void:
	_on_stop_button_pressed()
	# Delay needed to fix bug with seeking
	await get_tree().create_timer(1.0).timeout
	if isLoop:
		print("Looping!")
		updateSong()
		trackOption.select(currentTrackNum)
		_on_play_button_pressed()
	elif isShuffle:
		print("Shuffling!")
		# Catch Repeat TrackNum
		var prevTrackNum = currentTrackNum
		while prevTrackNum == currentTrackNum:
			currentTrackNum = randi_range(0, currentAlbum.tracks.size())
		updateSong()
		trackOption.select(currentTrackNum)
		_on_play_button_pressed()
	else:
		print("All music is done!")


func _on_loop_button_toggled(toggled_on: bool) -> void:
	isLoop = toggled_on
	if(isLoop):
		print("LOOPING ON")
		MusicManager.sfx_player.play_SFX_from_library("mp_Stop")
	if isLoop && isShuffle:
		shuffleButton.button_pressed = false

func _on_shuffle_toggled(toggled_on: bool) -> void:
	isShuffle = toggled_on
	if(isShuffle):
		print("SHUFFLE ON")
		MusicManager.sfx_player.play_SFX_from_library("mp_Stop")
	if isLoop && isShuffle:
		loopButton.button_pressed = false

func _on_seek_slider_drag_started() -> void:
	isSeeking = true
	_on_pause_button_pressed()

func _on_seek_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		MusicManager.current_player.seek(seekSlider.value)
	_on_play_button_pressed()


func _on_seek_forward_button_down() -> void:
	MusicManager.current_player.pitch_scale = 2.0

func _on_seek_forward_button_up() -> void:
	MusicManager.current_player.pitch_scale = 1.0


func _on_seek_back_button_down() -> void:
	isSeeking = true
	_on_pause_button_pressed()
	seekSlider.value -= 10

func _on_seek_back_button_up() -> void:
	MusicManager.current_player.seek(seekSlider.value)
	_on_play_button_pressed()
