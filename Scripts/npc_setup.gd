@tool
extends Node3D

@export var style_data: NpcStyle
var current_style := NpcStyle.new()
@onready var cube: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Cube_001
@onready var cube2: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Cube_002
@onready var skeleton_3d: Skeleton3D = $PersonAnimated/Armature/Skeleton3D
@onready var gun_holder: Node3D = $PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var animation_player: AnimationPlayer = $PersonAnimated/AnimationPlayer
@export var set_style := false : set = set_materials_editor
var faction_colors := {
	0 : Color(1.0, 1.0, 1.0, 1.0),
	1: Color(0.0, 0.0, 1.0, 1.0),
	2: Color(0.702, 0.0, 1.0, 1.0),
	3: Color(0.866, 0.0, 0.0, 1.0)
}

func _ready() -> void:
	#await get_tree().create_timer(1).timeout
	set_materials(style_data)


func set_materials_editor(_b: bool) -> void:
	set_materials()


func set_materials(style: NpcStyle = style_data) -> void:
	# Create unique material instances
	var face_material = cube.get_surface_override_material(0).duplicate()
	var shirt_material = cube2.get_surface_override_material(0).duplicate()
	var pants_material = cube2.get_surface_override_material(1).duplicate()
	var shoes_material = cube2.get_surface_override_material(2).duplicate()
	
	# Set the materials
	var skin_color = Color(0.937, 0.761, 0.604, 1.0)
	var hair_color = Color()
	if style.skin_colors.size() > 0:
		skin_color = style.skin_colors[randi() % style.skin_colors.size()]
	if style.hair_colors.size() > 0:
		hair_color = style.hair_colors[randi() % style.hair_colors.size()]
	var face_texture = style.faces[randi() % style.faces.size()]
	face_texture = get_texture_modified_skin(face_texture, skin_color, Color(0.933, 0.769, 0.6, 1.0))
	face_texture = get_texture_modified_skin(face_texture, hair_color, Color(0.133, 0.125, 0.208, 1.0))
	face_material.set("shader_parameter/base_texture", face_texture)
	var shirt_texture = style.shirts[randi() % style.shirts.size()]
	shirt_texture = get_texture_modified_skin(shirt_texture, skin_color, Color(0.933, 0.769, 0.6, 1.0))
	var faction = get_parent().faction
	var faction_color = faction_colors[faction]
	shirt_texture = get_texture_modified_skin(shirt_texture, faction_color, Color(0.957, 0.957, 0.957, 1.0))
	shirt_material.set("shader_parameter/base_texture", shirt_texture)
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
	current_style.faces.append(face_texture)
	current_style.shirts.clear()
	current_style.shirts.append(shirt_texture)
	current_style.pants_colors.clear()
	current_style.pants_colors.append(pants)
	current_style.shoe_colors.clear()
	current_style.shoe_colors.append(shoes)


func get_texture_modified_skin(texture: Texture, replace_color: Color, target_color: Color) -> Texture:
	var img = texture.get_image().duplicate()
	img.decompress()
	for x in img.get_width():
		for y in img.get_height():
			var c: Color = img.get_pixel(x, y)
			#if c.is_equal_approx(target_color):
			if (abs(c.r - target_color.r) < 0.1 and 
			abs(c.g - target_color.g) < 0.1 and 
			abs(c.b - target_color.b) < 0.1):
				img.set_pixel(x, y, replace_color)
	var new_texture = ImageTexture.create_from_image(img)
	return new_texture
