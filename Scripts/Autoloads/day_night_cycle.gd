extends Node

@export var time_curve: Curve
var total_cycle_seconds: float = 1000
var time: float = 0.25
var sun_time: float = 0.25
var time_speed: float
var sky_progress: float
var is_night: bool:
	get():
		return time <= 0 
signal night_start
signal day_start


func _ready() -> void:
	SceneManager.new_game_start.connect(reset_cycle)
	time_speed = 2 / total_cycle_seconds


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


func reset_cycle() -> void:
	time = 1.0
	time_speed = -0.01
	sun_time = 0.5


func save() -> Dictionary: 
	return {
		"time": time,
		"time_speed": time_speed,
		"sun_time": sun_time
	}
