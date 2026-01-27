@tool
extends Node3D

@export var objects_to_snap: Array[Node3D]
@export var snap := false : set = position_on_heightmap
@export var rotate := false : set = rotate_objects
@export var align_normal := false : set = align_to_normal
#@onready var terrain: Node3D = $"../../Terrain"
@onready var terrain: Node3D = $"../Terrain"


func position_on_heightmap(_value) -> void:
	for inst in objects_to_snap:
		var height = terrain.get_data().get_height_at(inst.global_position.x, inst.global_position.z)
		inst.global_position.y = height
		#terrain.get_data().get_normal_at


func rotate_objects(_value) -> void:
	for inst in objects_to_snap:
		inst.rotation.y = randf_range(0.0, deg_to_rad(360))


func align_to_normal(_value) -> void:
	if !is_inside_tree():
		return
	var space_state := get_world_3d().direct_space_state
	for child in objects_to_snap:
		if child is not Node3D:
			continue
		set_editable_instance(child, true)
		var origin = child.global_position + Vector3.UP * 0.5
		var target = origin + Vector3.DOWN * 5.0
		var query := PhysicsRayQueryParameters3D.create(origin, target)
		query.collide_with_areas = false
		query.collide_with_bodies = true
		if child is CollisionObject3D:
			query.exclude = [child]
		var result := space_state.intersect_ray(query)
		if result.is_empty():
			print("Ray did not hit terrain for ", child.name)
			continue
		var normal: Vector3 = result.normal.normalized()
		child.global_transform = align_with_y(child.global_transform, normal)
		print(child.name + " aligned")
		print(result.collider.name)
		print(normal)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
