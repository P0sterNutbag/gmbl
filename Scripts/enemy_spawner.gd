extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
@export var spawn_points: Array[Node3D]
var used_spawns: Array[int]


func _ready() -> void:
	spawn_points.append_array(get_children())
	if spawn_points.size() == 0:
		return
	
	# get enemy amount
	var enemy_amount = get_parent().location_data.population
	enemy_amount = clamp(enemy_amount, 0, spawn_points.size())
	await get_tree().process_frame
	
	# spawn quest enemy
	var quests = PlayerStats.quests.filter(func(i): 
		var quest_location = i.location
		var encounter_location = Globals.overworld.current_encounter.get_parent().title
		return quest_location == encounter_location)
	for quest in quests: 
		var inst = quest.target.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		var spawn_index = randi_range(0, spawn_points.size() - 1)
		used_spawns.append(spawn_index)
		inst.set_deferred("global_transform", spawn_points[spawn_index].global_transform)
		inst.bounty = quest
		enemy_amount -= 1
	
	# spawn enemies
	for i in enemy_amount:
		# get random enemy and spawn it
		var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
		var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
		
		# position enemy at spawn point
		var spawn_index = randi_range(0, spawn_points.size() - 1)
		while used_spawns.has(spawn_index):
			spawn_index = randi_range(0, spawn_points.size() - 1)
		used_spawns.append(spawn_index)
		inst.set_deferred("global_transform", spawn_points[spawn_index].global_transform)
		
		get_tree().current_scene.add_child.call_deferred(inst)
