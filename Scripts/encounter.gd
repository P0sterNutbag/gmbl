extends Node3D

@export var location_data: LocationData
@export var spawn_parents: Array[Node3D]


func _init() -> void:
	if Globals.overworld:
		var current_data = Globals.overworld.current_encounter.location_data
		location_data = current_data


func _exit_tree() -> void:
	var factions = []
	#var location_data = Globals.overworld.current_encounter.location_data
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.state != enemy.states.dead:
			if !factions.has(enemy.faction):
				factions.append(enemy.faction)
	var battle
	if Globals.overworld:
		battle = BattleManager.get_battle(Globals.overworld.current_encounter)
	if battle:
		for location in battle.all_locations:
			var data = location.location_data
			var population = enemies.filter(func(a): return a.state != a.states.dead and a.faction == data.faction).size()
			data.population = population
	else:
		location_data.population = enemies.filter(func(a): return a.state != a.states.dead and a.faction == location_data.faction).size()
	if factions.size() == 0:
		location_data.faction = FactionManager.factions.no_faction
		if battle: 
			battle.end_battle(Globals.overworld.current_encounter)
	elif factions.size() == 1:
		if battle:
			var winner = battle.all_locations.filter(func(a): return a.location_data.population > 0)[0]
			battle.end_battle(winner)
