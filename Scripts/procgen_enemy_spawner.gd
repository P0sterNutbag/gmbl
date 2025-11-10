extends Node3D

@export var enemies_to_spawn: Array[SpawnChance]
#@export var enemy_amount: int = 5
var spawn_radius: float = 8
var enemy_destination: Vector3
var enemies: Array


func _ready():
	var enemy_amount = randi_range(get_parent().location_data.min_population, get_parent().location_data.max_population)
	enemy_destination = position + Vector3(0, 0, -115)
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
		enemies.append(inst)
	#await get_tree().create_timer(1).timeout
	for enemy in enemies:
		enemy.change_state(enemy.states.walk)
