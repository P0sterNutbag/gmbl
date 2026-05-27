extends Node3D

#@export var npcs: Array[SpawnChance]
const NPC = preload("uid://b0cqkj1fgouo2")
var starting_enemy_count := 0
const NPC_ENEMY_DIALOGUE = preload("uid://d20coly46ve2b")
const NPC_FRIENDLY_DIALOGUE = preload("uid://cm4ovx7pecfjd")


func _ready() -> void:
	Globals.npc_controller = self


func _on_timer_timeout() -> void:
	# create enemy
	var inst = NPC.instantiate()
	Globals.overworld.add_child(inst)
	# determine spawn location
	var spawn_location = get_spawn_location()
	inst.global_position = spawn_location.global_position
	inst.global_position.y = Globals.get_heightmap_position(inst.global_position)
	inst.location.location_data.faction = spawn_location.location_data.faction
	inst.location.location_data.population = randi_range(min(2, spawn_location.location_data.population), min(4, spawn_location.location_data.population)) #max(spawn_location.location_data.population / 2, 1)
	inst.faction = spawn_location.location_data.faction
	var standing = FactionManager.get_faction_relation(inst.faction, FactionManager.factions.player)
	if standing < 0.0:
		inst.location.dialogue_tree = NPC_ENEMY_DIALOGUE.duplicate(true)
	else:
		inst.location.dialogue_tree = NPC_FRIENDLY_DIALOGUE.duplicate(true)
	# determine desination
	var dest = get_destination(inst.faction, spawn_location, inst.location.location_data)
	var pos = dest.global_position# + Vector3.RIGHT.rotated(Vector3.UP, deg_to_rad(randf_range(0, 360))) * dest.target_distance
	inst.navigation_agent.set_target_position(pos)
	inst.destination = dest


func get_spawn_location() -> Location:
	var nodes = get_tree().get_nodes_in_group("location")
	var node = nodes[randi() % nodes.size()]
	while !node.can_spawn_npcs or BattleManager.get_battle(node) != null:
		node = nodes[randi() % nodes.size()]
	return node


func get_destination(faction: FactionManager.factions, spawn_location: Node3D, npc_location_data: LocationData) -> Location:
	# get goal
	var faction_data = FactionManager.faction_data[faction]
	var rng = RandomNumberGenerator.new()
	var objectives = [0, 1, 2] # 0 = self, 1 = enemy, 2 = ally
	var weights = PackedFloat32Array([faction_data.defense, faction_data.agression, faction_data.enterprising])
	var goal = objectives[rng.rand_weighted(weights)]
	# get locaitons
	var all_nodes = get_tree().get_nodes_in_group("location")
	all_nodes.erase(spawn_location)
	all_nodes = all_nodes.filter(func(a): return a.can_spawn_npcs)
	if goal != 2:
		all_nodes = all_nodes.filter(func(a): return a.encounter_scene != null)
	var target_nodes = []
	for f in FactionManager.factions.size():
		var score = FactionManager.get_faction_relation(faction, f)
		if goal == 0:
			if f != faction:
				continue
		elif goal == 1:
			if score >= 0.0:
				continue
		elif goal == 2:
			if score < 0.0:
				continue
		var faction_locations = all_nodes.filter(func(a): return a.location_data.faction == f)
		target_nodes.append_array(faction_locations)
	if target_nodes.size() == 0:
		target_nodes = all_nodes
	target_nodes.sort_custom(func(a, b): return spawn_location.global_position.distance_to(a.global_position) < spawn_location.global_position.distance_to(b.global_position))
	#target_nodes.sort_custom(func(a, b): return a.location_data.population < b.location_data.population)
	rng.randomize()
	weights.clear()
	for i in target_nodes.size():
		var weight = max(target_nodes.size() - i, 1)
		if goal == 0 or goal == 1:
			var npc_population = npc_location_data.population
			var location_population = target_nodes[i].location_data.population
			var mult = float(npc_population) / maxf(1, location_population)
			weight *= mult
		weights.append(weight)
	var destination = target_nodes[rng.rand_weighted(weights)]
	#print(faction_data.name + " squad spawned at " + spawn_location.title + " en route to " + destination.title + ". Objective: " + str(goal))
	return destination
