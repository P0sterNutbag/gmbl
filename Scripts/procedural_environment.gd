extends Node3D

@export var maps: Array[ProcgenMap]
@export var cover_objects: Array[SpawnChance]
var edge_buffer: float = 30.0
var spawn_length: float = 256.0
var enemy_amount: int = 4
var cover_amount_min: int = 1
var cover_amount_max: int = 4
@onready var navigation_region_3d: NavigationRegion3D = $"../NavigationRegion3D"
@onready var cover_spawn: Node3D = $"../PlayerAnchor/CoverSpawn"


func _ready() -> void:
	generate_level()


func generate_level() -> void:
	for map in maps:
		for i in randi_range(map.min_amount, map.max_amount):
			# get building
			var index = Globals.get_weighted_index(map.objects)
			var inst = map.objects[index].object_to_spawn.instantiate()
			var spawn_pos = Vector3(randf_range(edge_buffer, spawn_length - edge_buffer), 0, randf_range(edge_buffer, spawn_length - edge_buffer))
			# get spawn pointz
			if navigation_region_3d.get_child_count() > 1:
				for child in navigation_region_3d.get_children():
					if !child.has_node("SpawnRadius") or !inst.has_node("SpawnRadius"):
						continue
					var min_dis = (child.get_node("SpawnRadius").position.x + inst.get_node("SpawnRadius").position.x)
					while spawn_pos.distance_to(child.global_position) < min_dis:
						spawn_pos = Vector3(randf_range(edge_buffer, spawn_length - edge_buffer), 0, randf_range(edge_buffer, spawn_length - edge_buffer))
			# spawn building
			spawn_pos.y = Globals.get_heightmap_position(spawn_pos)
			inst.position = spawn_pos
			inst.rotation.y = randf_range(0, TAU)
			navigation_region_3d.add_child(inst)
			if "align_on_procgen" in inst and inst.align_on_procgen:
				inst.align_to_normal(true)

	# create cover for player
	for i in randi_range(cover_amount_min, cover_amount_max):
		var cover = cover_objects[Globals.get_weighted_index(cover_objects)].object_to_spawn.instantiate()
		navigation_region_3d.add_child(cover)
		cover.global_position = cover_spawn.global_position + Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))
		cover.global_position.y = Globals.get_heightmap_position(cover.global_position)
		cover.rotation.y = randf_range(0, TAU)
	navigation_region_3d.bake_navigation_mesh()
