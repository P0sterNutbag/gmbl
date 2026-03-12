extends Node

var battles: Array[Battle]


func _ready() -> void:
	SceneManager.scene_changed.connect(_on_scene_changed)
	SceneManager.new_game_start.connect(_on_new_game_start)


func start_battle(location, attacking_location):
	var battle = get_battle(location)
	if battle:
		if !battle.all_locations.has(attacking_location):
			battle.attacker_locations.append(attacking_location)
	else:
		battle = Battle.new()
		battles.append(battle)
		battle.start_battle(location, attacking_location)


func delete_battle_at_location(location: Location):
	var battle = get_battle(location)
	battle.cleanup()


func get_battle(location: Location) -> Battle:
	for battle in battles:
		if battle.battle_location == location or battle.attacker_locations.has(location):
			return battle
	return null


func delete_all_battles() -> void:
	for child in get_children():
		child.queue_free()
	battles.clear()


func _on_scene_changed() -> void:
	if get_tree().current_scene != Globals.overworld:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT


func _on_new_game_start() -> void:
	delete_all_battles()
