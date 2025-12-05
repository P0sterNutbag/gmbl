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


func can_see_target(target: Node3D) -> bool:
	# point at target
	if !target:
		return false
	for child in target.aim_positions.get_children():
		target_pos = child.global_position
		look_at(target_pos)
		target_position.z = -global_position.distance_to(target_pos)
		# check for collisions
		var collider = get_collider()
		if collider:
			continue
		# check dot to target
		var forward = get_parent().global_transform.basis.z.normalized()
		var to_player = (target.global_transform.origin - get_parent().global_transform.origin).normalized()
		var dot_product = forward.dot(to_player)
		var dis_to_target = global_position.distance_to(target.position)
		if dot_product < -0.25 and dis_to_target <= range:
			return true
	return false
