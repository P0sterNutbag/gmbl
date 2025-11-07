extends Node3D

@export var npcs: Array[SpawnChance]
var npc_spawn_chance = 1
@export var locations: Array[Node3D]

func _ready() -> void:
	Globals.npc_controller = self


func _on_timer_timeout() -> void:
	if randf() < npc_spawn_chance:
		# make sure there are at least two usable locations
		#locations = Globals.overworld.get_children().filter(func(i): return i is Location)
		#if locations.filter(func(i): return i.location_data.population > 0).size() <= 1:
			#return
		var npc_to_spawn = npcs[Globals.get_weighted_index(npcs)].object_to_spawn
		var inst = npc_to_spawn.instantiate()
		Globals.overworld.add_child(inst)
		var spawn_location = locations[randi() % locations.size()].get_child(-1)
		while spawn_location.location_data.population == 0:
			spawn_location = locations[randi() % locations.size()].get_child(-1)
		if spawn_location.town == null:
			spawn_location.location_data.population = clamp(spawn_location.location_data.population - inst.location.location_data.population, 0, spawn_location.max_population)
		inst.global_position = spawn_location.global_position
		var dest = get_destination()
		while dest == spawn_location:
			dest = locations[randi() % locations.size()].get_child(-1)
		var pos = dest.global_position + Vector3.RIGHT.rotated(Vector3.UP, deg_to_rad(randf_range(0, 360))) * dest.target_distance
		inst.navigation_agent.set_target_position(pos)
		inst.destination = dest


func get_destination() -> Location:
	# return location instead and factor in target distance
	return locations[randi() % locations.size()].get_child(-1)
