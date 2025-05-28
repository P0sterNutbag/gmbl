extends Node3D

var end_point: Vector3

func _process(delta: float) -> void:
	global_translate(-global_transform.basis.z.normalized() * 175 * delta)
	if global_position.distance_to(end_point) < 3:
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
