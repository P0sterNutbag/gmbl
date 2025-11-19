@tool
extends Node3D

@export var terrain: Node3D
@export var buffer: float
@export var snap_to_terrain := false : set = position_on_terrain


func position_on_terrain(_value) -> void:
	if !terrain:
		return
	for child in get_children():
		var height = terrain.get_data().get_height_at(child.global_position.x, child.global_position.z)
		child.global_position.y = height + buffer
