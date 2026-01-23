extends RayCast3D

@export var view_angle: float = -0.25
@export var range: float = 50
var targets: Array[Node]
var target_pos: Vector3


func get_visible_target() -> Node:
	for target in targets:
		if can_see_target(target):
			return target
		else:
			continue
	return null


func can_see_target(target: Node3D = targets[0], check_direction: bool = true) -> bool:
	# point at target
	if !target:
		return false
	var target_positions = []
	if "aim_position" in target:
		target_positions = target.aim_positions.get_children()
	else:
		target_positions.append(target.global_position + Vector3.UP * 1.5)
	for i in target_positions:
		if i is Node3D:
			target_pos = i.global_position
		elif i is Vector3:
			target_pos = i
		var dis_to_target = global_position.distance_to(target_pos)
		if dis_to_target > range:
			continue
		look_at(target_pos)
		target_position.z = -global_position.distance_to(target_pos)
		# check for collisions
		var collider = get_collider()
		if collider:
			continue
		# check dot to target
		if !check_direction:
			return true
		var forward = get_parent().global_transform.basis.z.normalized()
		var to_player = (target.global_transform.origin - get_parent().global_transform.origin).normalized()
		var dot_product = forward.dot(to_player)
		if dot_product < -0.25:
			return true
	return false
