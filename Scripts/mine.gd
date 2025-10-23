extends Node3D
class_name Trap

var explosion_damage: float = 3.0
var explosion_force: float = 100
const EXPLOSION = preload("res://Scenes/Bullets/explosion_on_ground.tscn")
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func trigger() -> void:
	var inst = EXPLOSION.instantiate()
	get_tree().current_scene.add_child.call_deferred(inst)
	inst.global_position = global_position
	queue_free.call_deferred()


func _on_area_3d_body_entered(_body: Node3D) -> void:
	audio_stream_player_3d.play()
	await get_tree().create_timer(0.5).timeout
	trigger()
