@tool
extends Node3D

@export var maps: Array[ProcgenMap]
@export var generate_environment := false : set = generate_level
@export var clear_current_environment := false
@export var terrain: Node3D
var edge_buffer: float = 30.0
var spawn_length: float = 256.0
@onready var navigation_region_3d: NavigationRegion3D = $"../NavigationRegion3D"


func generate_level(_value: bool = false) -> void:
	if clear_current_environment:
		for child in navigation_region_3d.get_node("Generated").get_children():
			child.queue_free()
	for map in maps:
		for i in randi_range(map.min_amount, map.max_amount):
			# get building
			var inst = get_random_object(map.objects).instantiate()
			var spawn_pos = Vector3(randf_range(edge_buffer, spawn_length - edge_buffer), 0, randf_range(edge_buffer, spawn_length - edge_buffer))
			# get spawn points
			if navigation_region_3d.get_child_count() > 1:
				for child in navigation_region_3d.get_children():
					if !child.has_node("SpawnRadius") or !inst.has_node("SpawnRadius"):
						continue
					var min_dis = (child.get_node("SpawnRadius").position.x + inst.get_node("SpawnRadius").position.x)
					while spawn_pos.distance_to(child.global_position) < min_dis:
						spawn_pos = Vector3(randf_range(edge_buffer, spawn_length - edge_buffer), 0, randf_range(edge_buffer, spawn_length - edge_buffer))
			# spawn building
			spawn_pos.y = get_height_on_terrain(spawn_pos)
			inst.position = spawn_pos
			inst.rotation.y = randf_range(0, TAU)
			navigation_region_3d.get_node("Generated").add_child(inst)
			inst.set_owner(get_tree().edited_scene_root)
	generate_environment = false


func get_random_object(array: Array) -> PackedScene:
	var rng = RandomNumberGenerator.new()
	var amounts := []
	var weights: PackedFloat32Array
	for i in array.size():
		amounts.append(i)
		weights.append(array[i].spawn_chance)
	var index = rng.rand_weighted(weights)
	return array[index].object_to_spawn


func get_height_on_terrain(in_vector: Vector3) -> float:
	var height = terrain.get_data().get_height_at(in_vector.x, in_vector.z)
	in_vector.y = height
	return in_vector.y
