extends RayCast3D

@export var view_angle: float = -0.25
@export var range: float = 50
var target: Node3D


func _ready() -> void:
	target = Globals.player.camera
	look_at(target.global_position)


func _physics_process(delta: float) -> void:
	look_at(target.global_position)
	target_position.z = -global_position.distance_to(target.global_position)


func can_see_target() -> bool:
	#force_raycast_update()
	var collider = get_collider()
	if collider:
		return false
	var forward = get_parent().global_transform.basis.z.normalized()
	var to_player = (target.global_transform.origin - get_parent().global_transform.origin).normalized()
	var dot_product = forward.dot(to_player)
	var dis_to_target = global_position.distance_to(target.position)
	return dot_product < -0.25 and dis_to_target <= range
