extends Node3D

var wind_direction: float
var effect_range: float = 50.0
const WIND = preload("uid://bvcwp0tjcf7x8")
@onready var wind: GPUParticles3D = $Wind
@onready var player: Player = $"../Player"


func _process(_delta: float) -> void:
	wind.global_position = player.global_position


#func _on_timer_timeout() -> void:
	#var inst = WIND.instantiate()
	#var spawn_pos = -Vector3.ONE
	#while spawn_pos.x < 0 or spawn_pos.x > 275 or spawn_pos.z < 0 or spawn_pos.z > 275:
		#spawn_pos = Globals.player.global_position + Vector3(Vector3(randf_range(-effect_range,effect_range),randf_range(-effect_range,effect_range),randf_range(-effect_range,effect_range)))
	#spawn_pos.y = Globals.get_heightmap_position(spawn_pos)
	#get_parent().add_child(inst)
	#inst.global_position = spawn_pos
	#inst.rotation.y = deg_to_rad(wind_direction)
