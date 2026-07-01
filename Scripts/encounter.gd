extends Node3D

@export var location_data: LocationData
@export var spawn_parents: Array[Node3D]
var intel_timer: Timer


func _ready() -> void:
	if Globals.overworld:
		var current_data = Globals.overworld.current_encounter.location_data
		location_data = current_data
	intel_timer = Timer.new()
	add_child(intel_timer)
	intel_timer.wait_time = 60
	intel_timer.one_shot = true
	intel_timer.start()


func update_location_data() -> void:
	if Globals.overworld and intel_timer.time_left <= 0:
		var poi = Globals.overworld.current_encounter.point_of_interest
		poi.show_population = true
		poi.show_faction = true
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
		var filtered_enemies = enemies.filter(func(a): return a.state != a.states.dead and a.faction == location_data.faction)
		location_data.population = filtered_enemies.size()
		if Globals.overworld:
			var encounter_parent = Globals.overworld.current_encounter.get_parent()
			if encounter_parent is CharacterBody3D:
				if location_data.population == 0:
					encounter_parent.die()
	if factions.size() == 0:
		#location_data.faction = FactionManager.factions.no_faction
		if battle: 
			battle.end_battle(Globals.overworld.current_encounter)
	elif factions.size() == 1:
		if battle:
			var winner = battle.all_locations.filter(func(a): return a.location_data.population > 0)[0]
			battle.end_battle(winner)
	if Globals.overworld and Globals.overworld.current_encounter:
		Globals.overworld.current_encounter.location_data = location_data
