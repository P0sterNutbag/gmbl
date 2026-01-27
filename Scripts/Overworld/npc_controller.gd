extends Node3D

@export var npcs: Array[SpawnChance]
var starting_enemy_count := 0
var has_spawned_enemies: bool


func _ready() -> void:
	Globals.npc_controller = self
	if has_spawned_enemies:
		return
	for i in starting_enemy_count:
		var inst = npcs[1].object_to_spawn.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		#var enemy_pos = global_position + Vector3(randf_range(-50, 50), 0, randf_range(-50, 50))
		var spawn_points = get_tree().get_nodes_in_group("spawn points")
		var enemy_pos = spawn_points[randi() % spawn_points.size()].global_position
		enemy_pos.y = Globals.get_heightmap_position(enemy_pos)
		inst.set_deferred("global_position", enemy_pos)
		inst.look_at.call_deferred(enemy_pos + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)))
	has_spawned_enemies = true



func _on_timer_timeout() -> void:
	# make sure there are at least two usable locations
	#locations = Globals.overworld.get_children().filter(func(i): return i is Location)
	#if locations.filter(func(i): return i.location_data.population > 0).size() <= 1:
		#return
	# create enemy
	var npc_to_spawn = npcs[Globals.get_weighted_index(npcs)].object_to_spawn
	var inst = npc_to_spawn.instantiate()
	Globals.overworld.add_child(inst)
	# determine spawn location
	var spawn_location = get_destination()
	spawn_location.location_data.population = clamp(spawn_location.location_data.population - inst.location.location_data.population, 0, spawn_location.location_data.max_population)
	inst.global_position = spawn_location.global_position
	inst.global_position.y = Globals.get_heightmap_position(inst.global_position)
	inst.location.location_data.faction = spawn_location.location_data.faction
	inst.faction = spawn_location.location_data.faction
	# determine desination
	var dest = get_destination()
	while dest == spawn_location:
		dest = get_destination()
	var pos = dest.global_position# + Vector3.RIGHT.rotated(Vector3.UP, deg_to_rad(randf_range(0, 360))) * dest.target_distance
	inst.navigation_agent.set_target_position(pos)
	inst.destination = dest


func get_destination() -> Location:
	# return location instead and factor in target distance
	var nodes = get_tree().get_nodes_in_group("location")
	return nodes[randi() % nodes.size()]


func save() -> Dictionary:
	return {
		"has_spawned_enemies" = has_spawned_enemies
	}
