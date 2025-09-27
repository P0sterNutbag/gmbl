extends Node

@export var tracks: Dictionary[String, AudioStream]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	audio_stream_player.play()


func on_scene_transition(scene_name: String) -> void:
	var track = tracks[scene_name]
	audio_stream_player.stream = track
	audio_stream_player.play()
