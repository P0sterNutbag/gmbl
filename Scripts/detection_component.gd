extends RayCast3D

@export var view_angle: float = -0.25
@export var range: float = 50
var targets: Array[Node]


func get_visible_target() -> Node:
	for target in targets:
		if can_see_target(target):
			return target
		else:
			continue
	return null


func can_see_target(target: Node3D) -> bool:
	# point at target
	if !target:
		return false
	var target_pos = target.global_position + Vector3.UP * 1
	look_at(target_pos)
	target_position.z = -global_position.distance_to(target_pos)
	# check for collisions
	var collider = get_collider()
	if collider:
		return false
	# check dot to target
	var forward = get_parent().global_transform.basis.z.normalized()
	var to_player = (target.global_transform.origin - get_parent().global_transform.origin).normalized()
	var dot_product = forward.dot(to_player)
	var dis_to_target = global_position.distance_to(target.position)
	if dot_product < -0.25 and dis_to_target <= range:
		return true
	return false
