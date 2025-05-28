extends Camera3D


func screen_shake(magnitude: float = 0.1, shakes: int = 1):
	var previous_position = position
	for i in shakes:
		position.x += randf_range(-magnitude, magnitude)
		position.y += randf_range(-magnitude, magnitude)
		await get_tree().create_timer(0.05).timeout
		position = previous_position


func kickback(magnitude: float = 1):
	var tween = create_tween().set_ease(Tween.EASE_OUT)#.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_method(rotate_x, deg_to_rad(magnitude) / 3, deg_to_rad(magnitude) / 3, 0.05)
	#tween.tween_method(rotate_x, -deg_to_rad(magnitude), -deg_to_rad(magnitude) / 2, 0.1)
	#tween.set_parallel()
	#var y_rot = deg_to_rad(randf_range(-magnitude / 2, magnitude / 2))
	#tween.tween_method(rotate_y, y_rot, y_rot, 0.05)
	#rotate_x(deg_to_rad(magnitude))
	#rotate_y(deg_to_rad(randf_range(-magnitude / 2, magnitude / 2)))
