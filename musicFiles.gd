extends Node

var albumPath : String = "res://audio/music/Albums/"
var albumList : Array[MusicPlaylist]

#@export var imageDataString : String
#var file = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#file = FileAccess.open("imageTest.txt", FileAccess.WRITE)
	createAlbumList()
	#file.store_string(imageDataString)
	print(albumList)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func createAlbumList() -> void:
	# Check for Albums in Folder
	var aL : Array[MusicPlaylist]
	if ResourceLoader.list_directory(albumPath):
		var aLNames : PackedStringArray = ResourceLoader.list_directory(albumPath)
		for a in aLNames:
			# Check if Directory
			if not a.contains("/"):
				continue
			# Check for Music in Albums
			var album = MusicPlaylist.new()
			#print(a)
			var albumTracks : Array[MusicTrack]
			if ResourceLoader.list_directory(albumPath + a):
				var aTracks = ResourceLoader.list_directory(albumPath + a)
				for t in aTracks:
					# Check if music
					if not t.contains(".ogg"):
						continue
					var mTrack : MusicTrack = MusicTrack.new()
					# Import Metadata
					var stream = ResourceLoader.load(albumPath + a + t) as AudioStreamOggVorbis
					mTrack.track = stream
					var tags = stream.tags
					#for k in tags.keys():
						#print(k)
					#print()
					if tags.has("title"):
						mTrack.name = tags["title"]
					else:
						mTrack.name = t.left(-4)
					if tags.has("artist"):
						mTrack.artist = tags["artist"]
					else:
						mTrack.artist = a.left(-1)
					if tags.has("tracknumber"):
						mTrack.trackNum = tags["tracknumber"]
					if tags.has("metadata_block_picture"):
						# Remove image/jpeg header
						var imageIndex : int = tags["metadata_block_picture"].find("/9j/")
						var cleanString = tags["metadata_block_picture"].right(-imageIndex)
						var imageCover : Image = Image.new()
						var imageRaw : PackedByteArray = Marshalls.base64_to_raw(cleanString)
						#if imageDataString.is_empty():
							#imageDataString = tags["metadata_block_picture"]
						var error = imageCover.load_jpg_from_buffer(imageRaw)
						if error != OK:
							push_error("FAILED TO LOAD IMAGE FROM BUFFER")
						else:
							mTrack.coverArt = ImageTexture.create_from_image(imageCover)
							#print(mTrack.name + ": Cover ART FOUND")
					#print(t)
					albumTracks.append(mTrack)
			album.name = a.left(-1)
			albumTracks.sort_custom(func(x,y): return x.trackNum < y.trackNum)
			album.tracks = albumTracks
			aL.append(album)
	if aL.size() > 0:
		albumList = aL

func getAlbumList() -> Array[MusicPlaylist]:
	return albumList
