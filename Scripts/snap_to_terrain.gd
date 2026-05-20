@tool
extends Node3D

@export var position_on_start: bool
@export var position_all_nodes: bool: set = _position_all_nodes
@onready var terrain: Node3D = $"../Terrain"


func _ready() -> void:
	if position_on_start:
		_position_all_nodes()


func _position_all_nodes(_value = false) -> void:
	for inst in get_tree().get_nodes_in_group("align_aabb"):
		align_aabb(inst)
	for inst in get_tree().get_nodes_in_group("align_normal"):
		align_to_normal(inst)
	for inst in get_tree().get_nodes_in_group("align_position"):
		position_on_heightmap(inst)


func position_on_heightmap(inst: Node3D) -> void:
	var height = terrain.get_data().get_height_at(inst.global_position.x, inst.global_position.z)
	inst.global_position.y = height


func align_to_normal(inst: Node3D) -> void:
	if !is_inside_tree():
		return
	var space_state := get_world_3d().direct_space_state
	var origin = inst.global_position + Vector3.UP * 0.5
	var target = origin + Vector3.DOWN * 5.0
	var query := PhysicsRayQueryParameters3D.create(origin, target)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var to_exclude = []
	for i in inst.find_children("StaticBody3D"):
		if i is CollisionObject3D:
			to_exclude.append(i)
	query.exclude = to_exclude
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		print("empty result")
		return
	var normal: Vector3 = result.normal.normalized()
	var _scale = inst.scale
	inst.global_transform = align_with_y(inst.global_transform, normal)
	inst.scale = _scale
	position_on_heightmap(inst)
	print(inst.name + " aligned to normal")


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform


func align_aabb(inst: Node3D):
	var height = terrain.get_data().get_height_at(inst.global_position.x, inst.global_position.z)
	inst.global_position.y = height
	var aabb = inst.get_aabb()
	var local_corners = [
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z + aabb.size.z),
		Vector3(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z + aabb.size.z),
	]
	var largest_gap := 0.0
	for i in local_corners:
		var gap = inst.global_position.y - terrain.get_data().get_height_at((inst.global_position + i).x, (inst.global_position + i).z)
		if gap > largest_gap:
			largest_gap = gap
	inst.global_position.y -= largest_gap
