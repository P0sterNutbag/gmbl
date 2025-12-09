extends Node3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var health_component: HealthComponent = $Area3D
const RADIO_EXPLOSION = preload("uid://d3j7qlg8xyecf")


func _ready():
	audio_stream_player_3d.play()


func _on_death():
	var inst = RADIO_EXPLOSION.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = global_position
	inst.emitting = true
	audio_stream_player_3d.stop()
