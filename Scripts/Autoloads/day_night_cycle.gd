extends Node

@export var time_curve: Curve
var time: float = 1.0
var time_speed: float = 0.1
var sun_time: float = 0.5
var sky_progress: float


func _process(delta: float) -> void:
	time -= time_speed * delta
	if time >= time_curve.max_domain:
		time = time_curve.max_domain - 0.01
		time_speed *= -1
	if time <= time_curve.min_domain:
		time = time_curve.min_domain + 0.01
		time_speed *= -1
	sky_progress = (time + 1) / 2
	if time > 0:
		sun_time += abs(time_speed / 2) * delta
	else:
		sun_time = 0
	print(sun_time)
