extends Node3D

var wind_direction: float
var wind_speed: float = 20.0
var effect_range: float = 50.0
const WIND = preload("uid://blf0vdwe675ek")
@onready var gusts: Node3D = $Gusts


func _process(delta: float) -> void:
	for child in gusts.get_children():
		child.global_translate(-child.basis.z.normalized() * wind_speed * delta)


func _on_timer_timeout() -> void:
	var inst = WIND.instantiate()
	var spawn_pos = Globals.player.global_position + Vector3(50, 0, 0).rotated(Vector3.UP, wind_direction)
	spawn_pos.y = Globals.get_heightmap_position(spawn_pos)
	gusts.add_child(inst)
	inst.global_position = spawn_pos
	inst.look_at(Globals.player.global_position)
