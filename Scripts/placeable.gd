extends Node3D
class_name Placeable

var placed: bool = true
@export var meshes: Array[MeshInstance3D]


func _process(delta: float) -> void:
	if !placed:
		for mesh in meshes:
			mesh.transparency = 0.25
	else:
		for mesh in meshes:
			mesh.transparency = 0
