extends Node3D

@export var location_data: LocationData
@export var spawn_parents: Array[Node3D]


func _init() -> void:
	if Globals.overworld:
		location_data = Globals.overworld.current_encounter.location_data


#func _ready() -> void:
	## spawn minimum population
	##var spawn_amount = 
	#if spawn_parents.size() > 0:
		#for i in location_data.min_population:
			#var spawn_parent = spawn_parents[randi_range(0, spawn_parents.size() - 1)]
			#var children = spawn_parent.get_children()
			#var spawn_point = spawn_parent.get_children()[randi_range(0, children.size() - 1)]
			#var inst = spawn_parent.possible_spawns[Globals.get_weighted_index(spawn_parent.possible_spawns)].object_to_spawn.instantiate()
			#inst.set_deferred("global_position", spawn_point)
	## fill level with quest items
	#var relevant_quests = PlayerStats.quests.filter(func(i): 
		#var quest_location = i.location
		#var encounter_location = Globals.overworld.current_encounter.get_parent().title
		#return quest_location == encounter_location)
	#var enemies = []
	#if relevant_quests.size() > 0:
		#enemies = get_tree().get_nodes_in_group("enemies")
	#for quest in relevant_quests: 
		#var enemy = enemies[randi_range(0, enemies.size() - 1)]
		#enemy.bounty = quest
		#enemy.target_sprite.visible = true
