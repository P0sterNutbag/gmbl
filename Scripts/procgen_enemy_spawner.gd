extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
var spawn_radius: float = 8
var enemy_destination: Vector3
var enemies: Array
var location_data: LocationData
var squads: Array[LocationData]
const NPC = preload("uid://cb05x24r4r8im")


func _ready():
	if Globals.overworld:
		location_data = Globals.overworld.current_encounter.location_data
	else:
		location_data = get_parent().location_data
	var battle = BattleManager.get_battle(Globals.overworld.current_encounter)
	if battle:
		for location in battle.get_all_locations():
			squads.append(location.location_data)
	else:
		squads.append(location_data)
	await get_tree().process_frame
	var start_alert = false
	for squad in squads:
		var enemy_amount = squad.population#randi_range(squad.min_population, squad.max_population)
		var spawn_pos = Vector3.ZERO
		var dest = position + Vector3(0, 0, -115)
		if squads.find(squad) > 0:
			spawn_pos = Vector3(-64, 0.0, 0.0).rotated(Vector3.UP, deg_to_rad(randf_range(0, 360)))
			dest = position
		enemy_destination = dest
		if Globals.overworld:
			start_alert = Globals.overworld.current_encounter.alert_enemies
		if start_alert:
			dest = Globals.player.global_position
		# spawn enemies
		for i in enemy_amount:
			spawn_enemy(spawn_pos, squad.faction)
	# spawn player allies
	PlayerStats.ally_npcs.clear()
	for data in PlayerStats.allies:
		var inst = NPC.instantiate()
		inst.npc_data = data
		inst.faction = FactionManager.factions.player
		get_tree().current_scene.add_child(inst)
		inst.global_position = Globals.player.global_position + Vector3(randf_range(-5.0, 5.0), 0, randf_range(-5.0, 5.0))
		inst.global_position.y = Globals.get_heightmap_position(inst.global_position)
		inst.follow_target = Globals.player
		inst.goal = inst.goals.follow
		PlayerStats.ally_npcs.append(inst)
	await get_tree().process_frame
	for enemy in enemies:
		if start_alert:
			enemy.last_seen_position = Globals.player.position
			enemy.change_state(enemy.states.search)
		elif Globals.overworld and BattleManager.get_battle(Globals.overworld.current_encounter):
			var all_enemies = get_tree().get_nodes_in_group("enemies")
			all_enemies = all_enemies.filter(func(a): return FactionManager.get_faction_relation(enemy.faction, a.faction) < 0.0)
			all_enemies.sort_custom(func(a, b): return enemy.global_position.distance_to(a.global_position) < enemy.global_position.distance_to(b.global_position))
			enemy.last_seen_position = all_enemies[0].global_position
			enemy.change_state(enemy.states.search)
		else:
			enemy.change_state(enemy.states.walk)


func spawn_enemy(spawn_position: Vector3, faction: FactionManager.factions) -> void:
	# get random enemy and spawn it
	var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
	var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
	get_tree().current_scene.add_child.call_deferred(inst)
	# position enemy at spawn point
	var spawn_offset = spawn_position + Vector3(randf_range(-spawn_radius, spawn_radius), 0, randf_range(-spawn_radius, spawn_radius))
	var spawn_point = position + spawn_offset
	spawn_point.y = Globals.get_heightmap_position(spawn_point)
	inst.set_deferred("global_position", spawn_point)
	inst.destination = enemy_destination + spawn_offset
	inst.destination.y = Globals.get_heightmap_position(inst.destination)
	inst.goal = inst.goals.travel
	inst.look_at_position(inst.destination)
	inst.is_starting_squad = true
	inst.faction = faction
	enemies.append(inst)
