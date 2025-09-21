extends Node3D

@export var maps: Array[ProcgenMap]
@export var cover: Array[SpawnChance]
@export var spawn_radius = 40.0
var enemy_amount: int = 4
@onready var navigation_region_3d: NavigationRegion3D = $"../NavigationRegion3D"
@onready var cover_spawn: Node3D = $"../PlayerAnchor/CoverSpawn"


func _ready() -> void:
	generate_level()


#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("jump"):
		#for i in navigation_region_3d.get_children():
			#i.queue_free()
		#generate_level()


func generate_level() -> void:
	for map in maps:
		var spawn_center = Vector3.ZERO
		if map.cluster_radius > 0:
			spawn_center = get_weighted_position()
		for i in randi_range(map.min_amount, map.max_amount):
			# get building
			var index = Globals.get_weighted_index(map.objects)
			var inst = map.objects[index].object_to_spawn.instantiate()
			# get spawn point
			var spawn_pos = get_weighted_position(spawn_center, map.cluster_radius)
			if navigation_region_3d.get_child_count() > 1:
				for child in navigation_region_3d.get_children():
					if !child.has_node("SpawnRadius") or !inst.has_node("SpawnRadius"):
						continue
					var min_dis = (child.get_node("SpawnRadius").position.x + inst.get_node("SpawnRadius").position.x)
					while spawn_pos.distance_to(child.global_position) < min_dis:
						spawn_pos = get_weighted_position(spawn_center, map.cluster_radius)
			# spawn building
			inst.position = spawn_pos
			inst.rotation.y = randf_range(0, TAU)
			navigation_region_3d.add_child(inst)
	# create cover for player
	var inst = cover[Globals.get_weighted_index(cover)].object_to_spawn.instantiate()
	navigation_region_3d.add_child(inst)
	inst.global_position = cover_spawn.global_position + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	inst.rotation.y = randf_range(0, TAU)
	navigation_region_3d.bake_navigation_mesh()



func get_weighted_position(cluster_position: Vector3 = Vector3.ZERO, cluster_radius: float = 0) -> Vector3:
	if cluster_position == Vector3.ZERO:
		return Vector3(randf_range(-spawn_radius, spawn_radius), 0,randf_range(-spawn_radius, spawn_radius))
	else:
		return Vector3(cluster_position.x + randf_range(-cluster_radius, cluster_radius), 0, cluster_position.z + randf_range(-cluster_radius, cluster_radius))
	#var base_center: Vector3
	#if get_child_count() < 1:
		#base_center = Vector3.ZERO
	#else:
		#if randf() < 0.8:
			#base_center = get_child(-1).global_position
		#else:
			#base_center = Vector3(randf_range(-spawn_radius, spawn_radius), 0 ,randf_range(-spawn_radius, spawn_radius))
	#var radius = randf_range(0, 20)
	#var rx = pow(randf(), 2)
	#var x = lerp(-radius, radius, rx)
	#var rz = pow(randf(), 2)
	#var z = lerp(-radius, radius, rz)
	#var pos = base_center + Vector3(x, 0, z)
	#pos.x = clamp(pos.x, -spawn_radius, spawn_radius)
	#pos.z = clamp(pos.z, -spawn_radius, spawn_radius)
	#return pos


#func get_weigted_position(bias_center: Vector3 = Vector3.ZERO) -> Vector3:
	#var radius = randf_range(0, 20)
	#var rx = pow(randf(), 2)
	#var x = lerp(-radius, radius, rx) 
	#var rz = pow(randf(), 2)
	#var z = lerp(-radius, radius, rz)
	#var pos = bias_center + Vector3(x, 0, z)
	#pos.x = clamp(pos.x, -spawn_radius, spawn_radius)
	#pos.z = clamp(pos.z, -spawn_radius, spawn_radius)
	#return pos


#func get_weigted_position() -> Vector3:
	#var angle = randf() * TAU
	#var radius = pow(randf(), 2.0) * spawn_radius  # bias toward 0
	#var x = cos(angle) * radius
	#var z = sin(angle) * radius
	#return Vector3(x, 0, z)
