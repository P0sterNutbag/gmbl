extends Node3D

@onready var terrain_offset: Node3D = $TerrainOffset


func _process(delta: float) -> void:
	terrain_offset.position.z -= delta * 100
	print(terrain_offset.position.z)
	if terrain_offset.position.z <= -1024:
		terrain_offset.position.z = 0
