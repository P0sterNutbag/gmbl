extends Node

@export var tracks: Dictionary[String, AudioStream]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var ambient_sounds: AudioStreamPlayer = $AmbientSounds


func _ready() -> void:
	# signals
	SceneManager.scene_changed.connect(on_scene_changed)
	
	# get volume from settings
	#var master_index = AudioServer.get_bus_index("Master")
	#var value = ConfigManager.file.get_value("settings", "master_volume", 100)
	#AudioServer.set_bus_volume_db(master_index, linear_to_db(value / 100))
	#var music_index = AudioServer.get_bus_index("Music")
	#value = ConfigManager.file.get_value("settings", "music_volume", 100)
	#AudioServer.set_bus_volume_db(music_index, linear_to_db(value / 100))
	#var sfx_index= AudioServer.get_bus_index("Master")
	#value = ConfigManager.file.get_value("settings", "sfx_volume", 100)
	#AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	
	# start playing music
	var path = get_tree().current_scene.get_scene_file_path()
	if tracks.has(path):
		var track = tracks[path]
		audio_stream_player.stream = track
		audio_stream_player.play()
	audio_stream_player.play()


func on_scene_changed() -> void:
	# set ambient sounds
	ambient_sounds.stop()
	var scene_name = get_tree().current_scene.name
	if scene_name == "Encounter":
		ambient_sounds.play()
	# set music
	var scene_file_name = get_tree().current_scene.get_scene_file_path()
	if !tracks.has(scene_file_name):
		audio_stream_player.stop()
		return
	var track = tracks[scene_file_name]
	if audio_stream_player.stream == track:
		return
	audio_stream_player.stream = track
	audio_stream_player.play()
