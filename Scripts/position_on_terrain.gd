extends Node3D


#@onready var terrain: Node3D = $"../../Terrain"


func _ready() -> void:
	position_on_heightmap()


func position_on_heightmap() -> void:
	var terrain = get_tree().root.get_child(-1).get_node("Terrain")
	var height = terrain.get_data().get_height_at(global_position.x, global_position.z)
	global_position.y = height
