extends Node3D

@export var styles: NpcStyles
@onready var cube: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Cube
@onready var cube2: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Cube_001


func _ready() -> void:
	# Create unique material instances
	var face_material = cube.get_surface_override_material(0).duplicate()
	var shirt_material = cube2.get_surface_override_material(0).duplicate()
	var pants_material = cube2.get_surface_override_material(1).duplicate()
	var shoes_material = cube2.get_surface_override_material(2).duplicate()
	
	# Set the materials
	face_material.set("shader_parameter/base_texture", styles.faces[randi() % styles.faces.size()])
	shirt_material.set("shader_parameter/base_texture", styles.shirts[randi() % styles.shirts.size()])
	pants_material.set("shader_parameter/color", styles.pants_colors[randi() % styles.pants_colors.size()])
	shoes_material.set("shader_parameter/color", styles.shoe_colors[randi() % styles.shoe_colors.size()])
	
	# Apply the unique materials
	cube.set_surface_override_material(0, face_material)
	cube2.set_surface_override_material(0, shirt_material)
	cube2.set_surface_override_material(1, pants_material)
	cube2.set_surface_override_material(2, shoes_material)
