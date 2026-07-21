extends Node

@export var time_curve: Curve
var day_length := 480.0
var time: float = 60.0
var sun_time: float = 0.25
var time_speed: float = 1.0
var normalized_time: float
var half_day_length: float
var is_night: bool:
	get():
		return time > half_day_length 
signal night_start
signal day_start


func _ready() -> void:
	SceneManager.new_game_start.connect(reset_cycle)
	half_day_length = day_length / 2.0
	normalized_time = time / half_day_length


func _process(delta: float) -> void:
	if !get_tree().current_scene:
		return
	var scene_name = get_tree().current_scene.name
	if scene_name == "CharacterCreation" or scene_name == "MainMenu":
		return
	var was_night = is_night
	time += delta * time_speed
	if time >= day_length:
		time = 0
	if was_night != is_night:
		if time_speed < 0:
			night_start.emit()
		else:
			day_start.emit()
	normalized_time = time / day_length
	if !is_night:
		#sun_time += (delta / day_length * 0.75) * abs(time_speed)
		sun_time = time / half_day_length
	else:
		sun_time = 0


func reset_cycle() -> void:
	time = half_day_length / 4
	#time_speed = -0.01
	sun_time = 0.25


func skip_to_time(amount_to_skip: float) -> void:
	if amount_to_skip + normalized_time > 1:
		day_start.emit()
	normalized_time = wrap(normalized_time + amount_to_skip, 0, 1)
	time = day_length * normalized_time


func save() -> Dictionary: 
	return {
		"time": time,
		"time_speed": time_speed,
		"sun_time": sun_time
	}
