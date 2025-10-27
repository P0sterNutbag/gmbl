extends Node

@export var time_curve: Curve
var time: float = 1.0
var time_speed: float = -0.1
var sun_time: float = 0.5
var sky_progress: float
var is_night: bool:
	get():
		return time <= 0 
signal night_start
signal day_start


func _process(delta: float) -> void:
	var was_night = is_night
	time += time_speed * delta
	if time >= time_curve.max_domain:
		time = time_curve.max_domain - 0.01
		time_speed *= -1
	if time <= time_curve.min_domain:
		time = time_curve.min_domain + 0.01
		time_speed *= -1
	if was_night != is_night:
		if time_speed < 0:
			night_start.emit()
		else:
			day_start.emit()
	sky_progress = (time + 1) / 2
	if time > 0:
		sun_time += abs(time_speed / 2) * delta
	else:
		sun_time = 0
	print(sun_time)
