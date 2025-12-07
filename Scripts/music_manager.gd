extends Node

@export var tracks: Dictionary[String, AudioStream]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	SceneManager.scene_changed.connect(on_scene_changed)
	var path = get_tree().current_scene.get_scene_file_path()
	if tracks.has(path):
		var track = tracks[path]
		audio_stream_player.stream = track
		audio_stream_player.play()
	audio_stream_player.play()


func on_scene_changed() -> void:
	var scene_name = get_tree().current_scene.get_scene_file_path()
	if !tracks.has(scene_name):
		return
	var track = tracks[scene_name]
	if audio_stream_player.stream == track:
		return
	audio_stream_player.stream = track
	audio_stream_player.play()
