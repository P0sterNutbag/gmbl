extends Node3D

@onready var flag: MeshInstance3D = $MeshInstance3D
var flag_material: Material


func _ready() -> void:
	flag_material = flag.mesh.surface_get_material(0)


func _process(_delta: float) -> void:
	if get_tree().paused:
		flag_material.set_shader_parameter("time_scale", 0.0)
	else:
		flag_material.set_shader_parameter("time_scale", 0.3)
