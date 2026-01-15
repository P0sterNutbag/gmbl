extends Node

@export var time_curve: Curve
var total_cycle_seconds: float = 1200
var day_length = 600
var time: float = 0.25
var sun_time: float = 0.25
var time_speed: float
var normalized_time: float
var sky_progress: float
var is_night: bool:
	get():
		return time <= 0 
signal night_start
signal day_start


func _ready() -> void:
	SceneManager.new_game_start.connect(reset_cycle)
	time_speed = 2 / total_cycle_seconds
	sky_progress = (time + 1) / 2


func _process(delta: float) -> void:
	if !get_tree().current_scene:
		return
	var scene_name = get_tree().current_scene.name
	if !Globals.overworld or scene_name == "CharacterCreation" or scene_name == "MainMenu":
		return
	var was_night = is_night
	time += delta
	if time >= day_length:
		time = day_length - 0.01
		time_speed *= -1
	if time <= -day_length:
		time = day_length + 0.01
		time_speed *= -1
	if was_night != is_night:
		if time_speed < 0:
			night_start.emit()
		else:
			day_start.emit()
	normalized_time = time / day_length
	sky_progress = (normalized_time + 1) / 2
	if time > 0:
		sun_time += abs(time_speed / 2) * delta
	else:
		sun_time = 0


func reset_cycle() -> void:
	time = day_length
	time_speed = -0.01
	sun_time = 0.5


func save() -> Dictionary: 
	return {
		"time": time,
		"time_speed": time_speed,
		"sun_time": sun_time
	}
