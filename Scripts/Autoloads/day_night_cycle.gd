extends Node

@export var time_curve: Curve
var time: float = 1.0
var time_speed: float = 0.05
var sky_progress: float


func _process(delta: float) -> void:
	time -= time_speed * delta
	if time >= time_curve.max_domain or time <= time_curve.min_domain:
		time_speed *= -1
	sky_progress = (time + 1) / 2
	print(sky_progress)
