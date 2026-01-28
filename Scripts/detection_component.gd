extends ShapeCast3D

@export var view_angle: float = -0.25
@export var range: float = 50
var targets: Array[Node]
var target_pos: Vector3


func get_visible_target() -> Node:
	var in_range_targets = targets.filter(func(a): return global_position.distance_to(a.global_position) <= range)
	in_range_targets.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	for target in in_range_targets:
		if "states" in target and target.state == target.states.dead:
			targets.erase(target)
			continue
		if target and can_see_target(target):
			return target
		else:
			continue
	return null


func can_see_target(target: Node3D = targets[0], check_direction: bool = true) -> bool:
	# check for collision
	target_pos = target.global_position + Vector3.UP * 1.5
	look_at(target_pos)
	target_position.z = -global_position.distance_to(target_pos)
	force_shapecast_update() 
	if is_colliding():
		return false
	# check dot to target
	if !check_direction:
		return true
	var forward = get_parent().global_transform.basis.z.normalized()
	var to_player = (target.global_transform.origin - get_parent().global_transform.origin).normalized()
	var dot_product = forward.dot(to_player)
	if dot_product < -0.25:
		return true
	return false
