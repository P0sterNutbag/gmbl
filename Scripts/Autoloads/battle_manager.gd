extends Node

var battles: Array[Battle]


func _ready() -> void:
	SceneManager.scene_changed.connect(_on_scene_changed)


func start_battle(location, attacking_location):
	for battle in battles:
		if battle.battle_location == location or battle.attacker_locations.has(location):
			battle.attacker_locations.append(attacking_location)
			return
	var battle = Battle.new()
	battles.append(battle)
	battle.start_battle(location, attacking_location)


func end_battle_at_location(location: Location):
	for battle in battles:
		if battle.battle_location == location or battle.attacker_locations.has(location):
			battle.battle_timer.wait_time = 0.1


func _on_scene_changed() -> void:
	if get_tree().current_scene != Globals.overworld:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT
