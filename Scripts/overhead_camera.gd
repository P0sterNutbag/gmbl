extends Camera3D

enum camera_types {overhead, town}
var camera_type = camera_types.overhead
@onready var player: CharacterBody3D = $"../.."
@onready var town_shot: Node3D = %TownShot
@onready var overhead_shot: Node3D = %OverheadShot


func _process(delta: float) -> void:
	var camera_target: Node3D = overhead_shot
	if camera_type == camera_types.town:
		var rot = town_shot.rotation
		town_shot.look_at(Globals.overworld.current_encounter.global_position)
		town_shot.rotation = Vector3(rot.x, town_shot.rotation.y, rot.z)
		camera_target = town_shot
	global_position = lerp(global_position, camera_target.global_position, delta * 10)
	global_rotation.x = lerp_angle(global_rotation.x, camera_target.global_rotation.x, delta * 10)
	global_rotation.y = lerp_angle(global_rotation.y, camera_target.global_rotation.y, delta * 10)
	global_rotation.z = lerp_angle(global_rotation.z, camera_target.global_rotation.z, delta * 10)
