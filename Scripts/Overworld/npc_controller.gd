extends Node3D

const NPC = preload("uid://b0cqkj1fgouo2")
var starting_npcs := 3


func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	if SaveController.has_loaded:
		return
	var locations = get_tree().get_nodes_in_group("location")
	for i in starting_npcs:
		var location = locations[randi() % locations.size()]
		location.spawn_squad()

#
#func _ready() -> void:
	#Globals.npc_controller = self
#
#
#func _on_timer_timeout() -> void:
	## spawn npc
	#var spawn_location = get_spawn_location()
	#var inst = spawn_npc(spawn_location)
	## determine desination
	#var dest = get_destination(inst.faction, spawn_location, inst.location.location_data)
	#var pos = dest.global_position
	#inst.navigation_agent.set_target_position(pos)
	#inst.destination = dest
#
#
#func spawn_npc(location: Location) -> Node3D:
	#var location_data = location.location_data
	#var inst = NPC.instantiate()
	#inst.faction = location_data.faction
	#Globals.overworld.add_child(inst)
	#inst.location.location_data.faction = location_data.faction
	#inst.location.location_data.population = randi_range(min(2, location_data.population), min(4, location_data.population))
	#inst.location.location_data.firepower_chance = location_data.firepower_chance
	#inst.location.location_data.armor_level_chance = location_data.armor_level_chance
	#inst.global_position = location.global_position
	#inst.global_position.y = Globals.get_heightmap_position(inst.global_position)
	#var dest = get_destination(inst.faction, location, inst.location.location_data)
	#var pos = dest.global_position
	#inst.navigation_agent.set_target_position(pos)
	#inst.destination = dest
	#return inst
#
#
#func get_spawn_location() -> Location:
	#var nodes = get_tree().get_nodes_in_group("location")
	#var node = nodes[randi() % nodes.size()]
	#while !node.can_spawn_npcs or BattleManager.get_battle(node) != null:
		#node = nodes[randi() % nodes.size()]
	#return node
#
#
#func get_destination(faction: FactionManager.factions, spawn_location: Node3D, npc_location_data: LocationData) -> Location:
	## get goal
	#var faction_data = FactionManager.faction_data[faction]
	#var rng = RandomNumberGenerator.new()
	#var objectives = [0, 1, 2] # 0 = self, 1 = enemy, 2 = ally
	#var weights = PackedFloat32Array([faction_data.defense, faction_data.agression, faction_data.enterprising])
	#var goal = objectives[rng.rand_weighted(weights)]
	## get locaitons
	#var all_nodes = get_tree().get_nodes_in_group("location")
	#all_nodes.erase(spawn_location)
	#all_nodes = all_nodes.filter(func(a): return a.can_spawn_npcs)
	#if goal != 2:
		#all_nodes = all_nodes.filter(func(a): return a.encounter_scene != null)
	#var target_nodes = []
	#for f in FactionManager.factions.size():
		#var score = FactionManager.get_faction_relation(faction, f)
		#if goal == 0:
			#if f != faction:
				#continue
		#elif goal == 1:
			#if score >= 0.0:
				#continue
		#elif goal == 2:
			#if score < 0.0:
				#continue
		#var faction_locations = all_nodes.filter(func(a): return a.location_data.faction == f)
		#target_nodes.append_array(faction_locations)
	#if target_nodes.size() == 0:
		#target_nodes = all_nodes
	#target_nodes.sort_custom(func(a, b): return spawn_location.global_position.distance_to(a.global_position) < spawn_location.global_position.distance_to(b.global_position))
	#rng.randomize()
	#weights.clear()
	#for i in target_nodes.size():
		#var weight = max(target_nodes.size() - i, 1)
		#if goal == 0 or goal == 1:
			#var npc_population = npc_location_data.population
			#var location_population = target_nodes[i].location_data.population
			#var mult = float(npc_population) / maxf(1, location_population)
			#weight *= mult
		#weights.append(weight)
	#var destination = target_nodes[rng.rand_weighted(weights)]
	#return destination
