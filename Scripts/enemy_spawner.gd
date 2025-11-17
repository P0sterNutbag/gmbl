extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
@export var enemy_move_chance: float = 0.25 
var spawn_points: Array[Node3D]
var used_spawns: Array[int]


func _ready() -> void:
	# get spawn points
	var spawn_point_parents = get_tree().get_nodes_in_group("spawn points")
	for parent in spawn_point_parents:
		spawn_points.append_array(parent.get_children())
	
	# get quests
	var quests = PlayerStats.quests.filter(func(i): 
		var quest_location = i.location
		var encounter_location = Globals.overworld.current_encounter.point_of_interest.title
		return "target" in i and quest_location == encounter_location)
	
	# get enemy amount
	get_parent().location_data.min_population = clamp(get_parent().location_data.min_population, quests.size(), 1000)
	get_parent().location_data.min_population = clamp(get_parent().location_data.max_population, quests.size(), 1000)
	var enemy_amount = randi_range(get_parent().location_data.min_population, get_parent().location_data.max_population)
	enemy_amount = clamp(enemy_amount, 0, spawn_points.size())
	await get_tree().process_frame
	
	# spawn quest enemy
	for quest in quests: 
		var inst = quest.target.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		var spawn_index = randi_range(0, spawn_points.size() - 1)
		used_spawns.append(spawn_index)
		inst.set_deferred("global_transform", spawn_points[spawn_index].global_transform)
		inst.bounty = quest
		enemy_amount -= 1
		quest.target_node = inst
	
	# spawn enemies
	for i in enemy_amount:
		# get random enemy and spawn it
		var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
		var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		
		# position enemy at spawn point
		var spawn_index = randi_range(0, spawn_points.size() - 1)
		while used_spawns.has(spawn_index):
			spawn_index = randi_range(0, spawn_points.size() - 1)
		used_spawns.append(spawn_index)
		inst.set_deferred("global_transform", spawn_points[spawn_index].global_transform)
		
		# assign enemy a destination
		if randf() <= enemy_move_chance:
			var dest = get_destination(spawn_points[spawn_index].global_position)
			inst.destination = dest
			inst.change_state(inst.states.walk)


func get_destination(position_from: Vector3) -> Vector3:
	var dest_index = 0
	var dis = 0.0
	while dis <= 5:
		dest_index = randi_range(0, spawn_points.size() - 1)
		dis = position_from.distance_to(spawn_points[dest_index].global_position)
	return spawn_points[dest_index].global_position
