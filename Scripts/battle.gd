extends Resource
class_name Battle

var battle_location: Location
var attacker_locations: Array[Location]
@export_storage var time_left: float
@export_storage var location_path: String
@export_storage var attacker_paths: Array[String]
@export_storage var original_faction : FactionManager.factions


func start_battle(location: Location, attacking_location: Location) -> void:
	var location_data = location.location_data
	var attacker_data = attacking_location.location_data
	if location_data.population == 0:
		location_data.faction = attacker_data.faction
		location_data.population = min(attacker_data.population, location_data.max_population)
		Globals.survival_ui.create_notification(location.title + " taken by " + FactionManager.faction_data[location_data.faction].name)
		delete()
		return
	battle_location = location
	attacker_locations.append(attacking_location)
	var total_population = location_data.population
	total_population += attacker_data.population
	time_left = total_population * 2
	#BattleManager.add_child(battle_timer)
	#battle_timer.one_shot = true
	#battle_timer.start()
	#battle_timer.timeout.connect(_on_battle_timer_timeout)
	location.animation_player.play("battle")
	original_faction = battle_location.location_data.faction
	if location.can_spawn_npcs:
		Globals.survival_ui.create_notification(location.title + " under attack by " + FactionManager.faction_data[attacker_data.faction].name)


func end_battle(winner_location: Location = null) -> void:
	if !battle_location:
		delete()
		return
	if !battle_location.is_inside_tree():
		await battle_location.tree_entered
	if !winner_location:
		var location_lottery = []
		for i in battle_location.location_data.population:
			location_lottery.append(battle_location)
		for i in attacker_locations:
			var location_data = i.location_data
			for n in location_data.population:
				location_lottery.append(i)
		winner_location = location_lottery[randi() % location_lottery.size()]
	if battle_location.get_parent() is CharacterBody3D:
		# two npc fighting
		for location in get_all_locations():
			var npc = location.get_parent()
			if location != winner_location:
				npc.die()
			else:
				location.location_data.population = randi_range(1, location.location_data.population)
				npc.return_to_path()
	else:
		# npc takes over location
		for location in attacker_locations:
			var npc = location.get_parent()
			if location == winner_location:
				npc.queue_free()
			else:
				npc.die()
		battle_location.location_data.faction = winner_location.location_data.faction
		battle_location.location_data.population = max(randi() % battle_location.location_data.max_population + 1, 1)
	cleanup()


func get_all_locations() -> Array:
	var array = []
	array.append(battle_location)
	array.append_array(attacker_locations)
	return array


func save_battle() -> void:
	location_path = battle_location.get_path()
	attacker_paths.clear()
	for i in attacker_locations:
		attacker_paths.append(i.get_path())


func resume_battle() -> void:
	battle_location = Globals.get_tree().root.get_node(location_path)
	for i in attacker_paths:
		attacker_locations.append(Globals.get_tree().root.get_node(i))
	battle_location.animation_player.play("battle")


func cleanup() -> void:
	battle_location.animation_player.stop()
	if battle_location.location_data.faction != original_faction:
		Globals.survival_ui.create_notification(battle_location.title + " taken by " + FactionManager.faction_data[battle_location.location_data.faction].name)
	delete()


func delete() -> void:
	BattleManager.battles.erase(self)
