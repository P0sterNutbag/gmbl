extends Node3D

@export var npcs: Array[SpawnChance]
var npc_spawn_chance = 1


func _ready() -> void:
	Globals.npc_controller = self


func _on_timer_timeout() -> void:
	if randf() < npc_spawn_chance:
		# make sure there are at least two usable locations
		var locations = Globals.overworld.get_children().filter(func(i): return i is Location)
		#if locations.filter(func(i): return i.population > 0).size() <= 1:
			#return
		var npc_to_spawn = npcs[Globals.get_weighted_index(npcs)].object_to_spawn
		var inst = npc_to_spawn.instantiate()
		Globals.overworld.add_child(inst)
		var spawn_location = locations[randi() % locations.size()]
		while spawn_location.population == 0:
			spawn_location = locations[randi() % locations.size()]
		if spawn_location.town == null:
			spawn_location.population = clamp(spawn_location.population - inst.location.population, 0, spawn_location.max_population)
		inst.global_position = spawn_location.global_position
		var dest = spawn_location
		while dest == spawn_location:
			dest = locations[randi() % locations.size()]
		inst.navigation_agent.set_target_position(dest.global_position)
		inst.destination = dest
