extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
@export var enemy_move_chance: float = 0.25
@export var spawn_on_start: bool = true
var spawn_points: Array[Node3D]
var used_spawns: Array[int]
@onready var border_parent: Node3D = $"../Border"


func _ready() -> void:
	# get spawn points
	var spawn_point_parents = get_tree().get_nodes_in_group("spawn points")
	for parent in spawn_point_parents:
		spawn_points.append_array(parent.get_children())
	
	# get quests
	var quests = PlayerStats.quests.filter(func(i): 
		var quest_location = i.location
		var encounter_location = Globals.overworld.current_encounter.title
		return "target" in i and quest_location == encounter_location)
	
	if !spawn_on_start:
		return
	
	await get_tree().process_frame
	
	# get enemy amount
	var location_data
	if Globals.overworld:
		location_data = Globals.overworld.current_encounter.location_data
	else:
		location_data = get_parent().location_data
	var enemy_amount: int
	#if location_data.population < location_data.min_population:
	enemy_amount = location_data.population
	#else: 
	#	enemy_amount = randi_range(location_data.min_population, location_data.max_population)
	enemy_amount = clamp(enemy_amount, quests.size(), spawn_points.size())
	
	# spawn quest enemy
	for quest in quests: 
		var inst = quest.target.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		var spawn_index = randi_range(0, spawn_points.size() - 1)
		used_spawns.append(spawn_index)
		inst.set_deferred("global_transform", spawn_points[spawn_index].global_transform)
		inst.bounty = quest
		inst.faction = location_data.faction
		enemy_amount -= 1
		quest.target_node = inst
	
	# spawn enemies
	for i in enemy_amount:
		spawn_enemy(location_data.faction)
	
	# spawn enemies for battle
	var battle
	if Globals.overworld:
		battle = BattleManager.get_battle(Globals.overworld.current_encounter)
	if battle:
		for attacker in battle.attacker_locations:
			for i in attacker.location_data.population:
				spawn_enemy(attacker.location_data.faction)
	
	
	# spawn player allies
	for ally in PlayerStats.allies:
		var inst = ally.instantiate()
		get_tree().current_scene.add_child(inst)
		inst.global_position = Globals.player.global_position + Vector3(randf_range(-5.0, 5.0), 0, randf_range(-5.0, 5.0))
		inst.global_position.y = Globals.get_heightmap_position(inst.global_position)
		inst.state = inst.states.walk
	
	# spawn wandering squads
	if randf() <= location_data.squad_spawn_chance:
		if Globals.overworld:
			if !BattleManager.get_battle(Globals.overworld.current_encounter):
				return
		# get spawn and destination positions
		var borders = border_parent.get_children().filter(func(a): return a.process_mode == PROCESS_MODE_INHERIT)
		var border_index = randi_range(0, borders.size() - 1)
		while borders[border_index].global_position.distance_to(Globals.player.global_position) < 50:
			border_index = randi_range(0, borders.size() - 1)
		var border = borders[border_index]
		var spawn_point = border.global_position
		var border_index2 = wrap(border_index + (borders.size() / 2.0), 0, borders.size())
		while border_index2 == border_index:
			border_index2 = randi_range(0, borders.size() - 1)
		var destination = borders[border_index2].global_position
		# get faction
		var faction = randi() % FactionManager.factions.size()
		while faction == FactionManager.factions.player:
			faction = randi() % FactionManager.factions.size()
		# spawn enemies
		for i in randf_range(1, 4):
			var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
			var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
			inst.faction = faction
			get_tree().current_scene.add_child.call_deferred(inst)
			var offset = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
			var pos = spawn_point + offset
			pos.x = clamp(pos.x, 1.0, 255.0)
			pos.z = clamp(pos.z, 1.0, 255.0)
			pos.y = Globals.get_heightmap_position(pos) + 0.25
			inst.set_deferred("global_position", pos)
			inst.destination = destination + offset
			inst.look_at_position(inst.destination)
			inst.change_state(inst.states.walk)
	
	# make enemies fight if theres a battle
	if Globals.overworld and BattleManager.get_battle(Globals.overworld.current_encounter):
		for enemy in get_tree().get_nodes_in_group("enemies"):
			var all_enemies = get_tree().get_nodes_in_group("enemies")
			all_enemies = all_enemies.filter(func(a): return FactionManager.get_faction_relation(enemy.faction, a.faction) < 0.0)
			all_enemies.sort_custom(func(a, b): return enemy.global_position.distance_to(a.global_position) < enemy.global_position.distance_to(b.global_position))
			enemy.last_seen_position = all_enemies[0].global_position
			enemy.change_state(enemy.states.search)


func get_destination(position_from: Vector3) -> Vector3:
	var dest_index = 0
	var dis = 0.0
	while dis <= 5:
		dest_index = randi_range(0, spawn_points.size() - 1)
		dis = position_from.distance_to(spawn_points[dest_index].global_position)
	return spawn_points[dest_index].global_position


func spawn_enemy(faction: FactionManager.factions):
	# get random enemy and spawn it
	var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
	var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
	# assign faction
	inst.faction = faction
	# add to scene
	get_tree().current_scene.add_child.call_deferred(inst)
	# position enemy at spawn point
	var spawn_index = randi_range(0, spawn_points.size() - 1)
	while used_spawns.has(spawn_index) or spawn_points[spawn_index].process_mode == PROCESS_MODE_DISABLED:
		spawn_index = randi_range(0, spawn_points.size() - 1)
	used_spawns.append(spawn_index)
	inst.set_deferred("global_transform", spawn_points[spawn_index].global_transform)
	# assign enemy a destination
	if randf() <= enemy_move_chance:
		var dest = get_destination(spawn_points[spawn_index].global_position)
		inst.destination = dest
		inst.change_state(inst.states.walk)
