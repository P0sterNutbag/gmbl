extends Node3D

@export var possible_spawns: Array[SpawnChance]
@export var spawn_chance: float = 0
@export var spawn_amount_min: int = 1
@export var spawn_amount_max: int = 3
@export var location_data_variable: String
@export var spawn_on_heightmap: bool = true
@export var face_away_from_center: bool = true
var used_spawns: Array[int]


func _ready() -> void:
	if location_data_variable == "npc_spawn_chance":
		get_tree().root.get_node("Encounter/EnemySpawner").spawn_points.append_array(get_children())
	if spawn_on_heightmap:
		for child in get_children():
			position_on_heightmap(child)
			if face_away_from_center:
				child.look_at(global_position)
				child.rotate_y(deg_to_rad(180))
				child.global_rotation.x = 0
				child.global_rotation.z = 0
	#await get_tree().process_frame
	#if "location_data" in get_tree().current_scene:
		#spawn_chance = get_tree().current_scene.location_data.get(location_data_variable)
	#var spawn_amount = randi_range(spawn_amount_min, spawn_amount_max)
	#if randf() <= spawn_chance:
		#for i in spawn_amount:
			#spawn()


func spawn():
	var spawns = get_children()
	var index = randi_range(0, spawns.size() - 1)
	if used_spawns.size() < spawns.size():
		while used_spawns.has(index):
			index = randi_range(0, spawns.size() - 1)
	var loot_to_spawn = possible_spawns[Globals.get_weighted_index(possible_spawns)].object_to_spawn
	var inst = loot_to_spawn.instantiate()
	get_tree().current_scene.add_child.call_deferred(inst)
	inst.global_transform = spawns[index].global_transform
	used_spawns.append(index)


func position_on_heightmap(node: Node3D) -> void:
	var terrain = get_tree().root.get_child(-1).get_node("Terrain")
	var height = terrain.get_data().get_height_at(global_position.x, global_position.z)
	node.global_position.y = height
	if location_data_variable == "npc_spawn_chance":
		node.global_position.y += 0.5
