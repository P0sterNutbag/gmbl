extends Node

@export var level_rewards : Array[Resource]
var progress_data := ProgressData.new()
var kills = 0


func _ready() -> void:
	if ResourceLoader.exists("user://progress_data.res"):
		progress_data = ResourceLoader.load("user://progress_data.res")


func apply_progress() -> void:
	var old_level = progress_data.level
	progress_data.add_xp(kills * 110)
	var new_level = progress_data.level
	if old_level < progress_data.level:
		var starting_gear = load("res://Resources/SaveData/starting_gear.tres")
		if ResourceLoader.exists("user://starting_gear.res"):
			starting_gear = ResourceLoader.load("user://starting_gear.res")
		for i in range(old_level + 1, new_level):
			starting_gear.add_item(level_rewards[i - 2])
		ResourceSaver.save(starting_gear, "user://starting_gear.res")
	save_progress_data()


func save_progress_data() -> void:
	ResourceSaver.save(progress_data, "user://progress_data.res")


func save() -> Dictionary:
	return {
		"kills": kills,
	}
