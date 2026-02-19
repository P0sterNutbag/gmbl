extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
var spawn_radius: float = 8
var enemy_amount: int
var enemy_destination: Vector3
var enemies: Array


func _ready():
	var location_data
	if Globals.overworld:
		location_data = Globals.overworld.current_encounter.location_data
	else:
		location_data = get_parent().location_data
	enemy_amount = randi_range(location_data.min_population, location_data.max_population)
	var dest = position + Vector3(0, 0, -115)
	var start_alert = false
	if Globals.overworld:
		start_alert = Globals.overworld.current_encounter.alert_enemies
	if start_alert:
		dest = Globals.player.global_position
	enemy_destination = dest
	await get_tree().process_frame
	# spawn enemies
	for i in enemy_amount:
		# get random enemy and spawn it
		var enemy_index = Globals.get_weighted_index(enemies_to_spawn)
		var inst = enemies_to_spawn[enemy_index].object_to_spawn.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		# position enemy at spawn point
		var spawn_offset = Vector3(randf_range(-spawn_radius, spawn_radius), 0, randf_range(-spawn_radius, spawn_radius))
		var spawn_point = position + spawn_offset
		spawn_point.y = Globals.get_heightmap_position(spawn_point)
		inst.set_deferred("global_position", spawn_point)
		inst.destination = enemy_destination + spawn_offset
		inst.destination.y = Globals.get_heightmap_position(inst.destination)
		inst.look_at_position(inst.destination)
		inst.is_starting_squad = true
		inst.faction = location_data.faction
		enemies.append(inst)
	for enemy in enemies:
		if start_alert:
			enemy.last_seen_position = Globals.player.position
			enemy.change_state(enemy.states.search)
		else:
			enemy.change_state(enemy.states.walk)
