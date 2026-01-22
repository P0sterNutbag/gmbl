@tool
extends Node3D
@export_category("Spawning")
@export var spawn_npcs: bool
@export var spawn_loot: bool
@export var spawn_traps: bool
@export_category("Position Children")
@export var terrain: Node3D
@export var nodes_to_exclude: Array[Node3D]
@export var buffer: float
@export var snap_to_terrain := false : set = position_on_terrain
@export var spin := false : set = rotate_objects
@export var align_normal := false : set = align_to_normal
@export var align_on_procgen := false 
#@export_tool_button("snap", "Area2D") var action = position_on_terrain
@onready var npc_spawns: Node3D = $NpcSpawns
@onready var loot_spawns: Node3D = $LootSpawns
@onready var trap_spawns: Node3D = $TrapSpawns


func _enter_tree() -> void:
	if npc_spawns:
		if !spawn_npcs: npc_spawns.process_mode = Node.PROCESS_MODE_DISABLED
		else: npc_spawns.process_mode = Node.PROCESS_MODE_INHERIT
	if loot_spawns:
		if !spawn_loot: loot_spawns.process_mode = Node.PROCESS_MODE_DISABLED
		else: loot_spawns.process_mode = Node.PROCESS_MODE_INHERIT
	if trap_spawns:
		if !spawn_traps: trap_spawns.process_mode = Node.PROCESS_MODE_DISABLED
		else: trap_spawns.process_mode = Node.PROCESS_MODE_INHERIT


func position_on_terrain(_value) -> void:
	if !terrain:
		return
	var height = terrain.get_data().get_height_at(global_position.x, global_position.z)
	global_position.y = height + buffer
	for child in get_children():
		if nodes_to_exclude.has(child):
			continue
		set_editable_instance(child, true)
		height = terrain.get_data().get_height_at(child.global_position.x, child.global_position.z)
		child.global_position.y = height + buffer


func rotate_objects(_value) -> void:
	rotation.y = randf_range(0.0, deg_to_rad(360))
	#for child in get_children():
		#set_editable_instance(child, true)
		#child.rotation.y = randf_range(0.0, deg_to_rad(360))


#func align_to_normal(_value) -> void:
	#for child in get_children():
		#if !ray_cast_3d or child is RayCast3D:
			#continue
		#var raycast_parent = ray_cast_3d.get_parent()
		#raycast_parent.remove_child(ray_cast_3d)
		#child.add_child(ray_cast_3d)
		#ray_cast_3d.force_raycast_update()
		#if !ray_cast_3d.is_colliding():
			#print("raycast not colliding")
			#continue
		#var normal = ray_cast_3d.get_collision_normal().normalized()
		#child.global_transform = align_with_y(global_transform, normal)
		##print(child.name + " aligned")
		##if child is npc_spawns or child is loot_spawns or child is trap_spawns:
			##for child in child.get_children():
				#
	#if ray_cast_3d:
		#var parent = ray_cast_3d.get_parent()
		#parent.remove_child(ray_cast_3d)
		#add_child(ray_cast_3d)


func align_to_normal(_value) -> void:
	if !is_inside_tree():
		return
	var space_state := get_world_3d().direct_space_state
	for child in get_children():
		if child is not Node3D:
			continue
		if child == npc_spawns or child == loot_spawns or child == trap_spawns or nodes_to_exclude.has(child):
			continue
		set_editable_instance(child, true)
		#global_position += Vector3.UP * 2
		var origin = child.global_position + Vector3.UP * 0.5
		var target = origin + Vector3.DOWN * 5.0
		var query := PhysicsRayQueryParameters3D.create(origin, target)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		if child is CollisionObject3D:
			query.exclude = [child]
		for child2 in child.get_children():
			if child2 is CollisionObject3D:
				query.exclude = [child2]
			for child3 in child2.get_children():
				if child3 is CollisionObject3D:
					query.exclude = [child3]
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			print("Ray did not hit terrain for ", child.name)
			continue
		var normal: Vector3 = result.normal.normalized()
		child.global_transform = align_with_y(child.global_transform, normal)
		#global_position -= Vector3.UP * 2
		print(child.name + " aligned")
		print(result.collider.name)
		print(normal)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
