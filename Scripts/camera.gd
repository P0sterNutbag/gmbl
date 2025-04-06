extends Camera3D


func screen_shake(magnitude: float = 0.1, shakes: int = 1):
	var previous_position = position
	for i in shakes:
		position.x += randf_range(-magnitude, magnitude)
		position.y += randf_range(-magnitude, magnitude)
		await get_tree().create_timer(0.05).timeout
		position = previous_position


func kickback(magnitude: float = 1):
	#var tween = create_tween()
	#tween.tween_method(rotate_x, 0, deg_to_rad(magnitude), 0.05)
	#tween.set_parallel()
	#tween.tween_method(rotate_y, 0, deg_to_rad(randf_range(-magnitude / 2, magnitude / 2)), 0.05)
	rotate_x(deg_to_rad(magnitude))
	rotate_y(deg_to_rad(randf_range(-magnitude / 2, magnitude / 2)))
