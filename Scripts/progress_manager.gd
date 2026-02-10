extends Node

@export var level_rewards : Array[Resource]
var progress_data := ProgressData.new()
var kills = 0
var quests_completed = 0
var awards := []
var progress_path = "user://progress_data.res"
var gear_path = "user://starting_gear.res"
const starting_gear = preload("uid://dpjy0ettwaiyp")


func _ready() -> void:
	if ResourceLoader.exists(progress_path):
		progress_data = ResourceLoader.load(progress_path)


func apply_progress() -> void:
	awards.clear()
	var old_level = progress_data.level
	progress_data.add_xp(kills * 5)
	progress_data.add_xp(quests_completed * 10)
	var new_level = progress_data.level
	if old_level < progress_data.level:
		var saved_gear
		if ResourceLoader.exists(gear_path):
			saved_gear = ResourceLoader.load(gear_path).duplicate(true)
		else:
			saved_gear = starting_gear.duplicate(true)
		for i in range(old_level, new_level):
			if level_rewards.size() < i:
				continue
			var item = level_rewards[i - 1]
			awards.append(item)
			if item is ItemMoney:
				progress_data.starting_money += item.price
				continue
			if item is EquipmentGun:
				var ammo_item = Globals.player.get(item.resource_name).ammo_item
				for ii in 3:
					awards.append(ammo_item)
				pass
			for award in awards:
				saved_gear.add_item(award)
		ResourceSaver.save(saved_gear, gear_path)
	save_progress_data()


func save_progress_data() -> void:
	ResourceSaver.save(progress_data, progress_path)


func save() -> Dictionary:
	return {
		"kills": kills,
		"quests_completed" : quests_completed,
	}
