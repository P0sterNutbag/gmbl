extends Node3D

@export var style_data: NpcStyle
var current_style := NpcStyle.new()
@onready var cube: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Cube
@onready var cube2: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Cube_001


func _ready() -> void:
	set_materials(style_data)


func set_materials(style: NpcStyle) -> void:
	# Create unique material instances
	var face_material = cube.get_surface_override_material(0).duplicate()
	var shirt_material = cube2.get_surface_override_material(0).duplicate()
	var pants_material = cube2.get_surface_override_material(1).duplicate()
	var shoes_material = cube2.get_surface_override_material(2).duplicate()
	
	# Set the materials
	var face = style.faces[randi() % style.faces.size()]
	face_material.set("shader_parameter/base_texture", face)
	var shirt = style.shirts[randi() % style.shirts.size()]
	shirt_material.set("shader_parameter/base_texture", shirt)
	var pants = style.pants_colors[randi() % style.pants_colors.size()]
	pants_material.set("shader_parameter/color", pants)
	var shoes = style.shoe_colors[randi() % style.shoe_colors.size()]
	shoes_material.set("shader_parameter/color", shoes)
	
	# Apply the unique materials
	cube.set_surface_override_material(0, face_material)
	cube2.set_surface_override_material(0, shirt_material)
	cube2.set_surface_override_material(1, pants_material)
	cube2.set_surface_override_material(2, shoes_material)
	
	# Set current style
	current_style.faces.clear()
	current_style.faces.append(face)
	current_style.shirts.clear()
	current_style.shirts.append(shirt)
	current_style.pants_colors.clear()
	current_style.pants_colors.append(pants)
	current_style.shoe_colors.clear()
	current_style.shoe_colors.append(shoes)
