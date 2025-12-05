@tool
extends Node

@export var objects_to_snap: Array[Node3D]
@export var snap := false : set = position_on_heightmap
@export var rotate := false : set = rotate_objects
#@onready var terrain: Node3D = $"../../Terrain"
@onready var terrain: Node3D = $"../Terrain"


func position_on_heightmap(_value) -> void:
	for inst in objects_to_snap:
		var height = terrain.get_data().get_height_at(inst.global_position.x, inst.global_position.z)
		inst.global_position.y = height
		terrain.get_data().get_normal_at


func rotate_objects(_value) -> void:
	for inst in objects_to_snap:
		inst.rotation.y = randf_range(0.0, deg_to_rad(360))
