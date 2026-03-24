@tool
extends Path3D

@export var snap_to_terrain := false : set = _snap_to_terrain
@onready var terrain: Node3D = $"../Terrain"


func _snap_to_terrain(_value) -> void:
	for i in curve.point_count:
		var pos = curve.get_point_position(i)
		pos.y = terrain.get_data().get_height_at(pos.x, pos.z)
		curve.set_point_position(i, pos)
