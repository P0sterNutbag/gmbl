extends Node

@export var time_curve: Curve
var day_length := 480.0
var time: float = 240.0
var sun_time: float = 0.25
var time_speed: float = 1.0
var normalized_time: float
var half_day_length: float
var sky_progress: float
var is_night: bool:
	get():
		return time <= 0 
signal night_start
signal day_start


func _ready() -> void:
	SceneManager.new_game_start.connect(reset_cycle)
	half_day_length = day_length / 2.0
	normalized_time = time / half_day_length
	sky_progress = (normalized_time + 1.0) / 2.0


func _process(delta: float) -> void:
	if !get_tree().current_scene:
		return
	var scene_name = get_tree().current_scene.name
	if !Globals.overworld or scene_name == "CharacterCreation" or scene_name == "MainMenu":
		return
	var was_night = is_night
	time += delta * time_speed
	if time >= half_day_length:
		time = half_day_length - 0.01
		time_speed = -1
	if time <= -half_day_length:
		time = -half_day_length + 0.01
		time_speed = 1
	if was_night != is_night:
		if time_speed < 0:
			night_start.emit()
		else:
			day_start.emit()
	normalized_time = time / half_day_length
	sky_progress = (normalized_time + 1.0) / 2.0
	if time > 0:
		sun_time += delta / day_length
	else:
		sun_time = 0


func reset_cycle() -> void:
	time = half_day_length / 2
	#time_speed = -0.01
	sun_time = 0.25


func skip_to_time(amount_to_skip: float) -> void:
	var starting_norm_time = normalized_time
	normalized_time += amount_to_skip * time_speed
	if abs(normalized_time) > 1:
		var overtime = abs(normalized_time) - 1
		normalized_time += overtime * -time_speed * 2
		time_speed *= -1
	time = half_day_length * normalized_time
	if starting_norm_time < 0.0 and normalized_time >= 0:
		day_start.emit()


func save() -> Dictionary: 
	return {
		"time": time,
		"time_speed": time_speed,
		"sun_time": sun_time
	}
