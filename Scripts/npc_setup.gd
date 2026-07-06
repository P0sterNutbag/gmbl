#@tool
extends Node3D
class_name CharacterSetup


@export var style_data: NpcStyle
var current_style := NpcStyle.new()
@onready var cube: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Head
@onready var cube2: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Body
@onready var skeleton_3d: Skeleton3D = $PersonAnimated/Armature/Skeleton3D
@onready var gun_holder: Node3D = $PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var animation_player: AnimationPlayer = $PersonAnimated/AnimationPlayer
@onready var vest: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Vest
@onready var helmet: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Helmet
@onready var pads: MeshInstance3D = $PersonAnimated/Armature/Skeleton3D/Pads
const BALD_HAIR = preload("uid://cfmrww0wj003t")


func _ready() -> void:
	var parent = get_parent()
	await get_tree().process_frame
	if "npc_data" in parent and parent.npc_data and parent.npc_data.style != null:
		style_data = parent.npc_data.style
	elif "faction" in parent and parent != Globals.player:
		style_data = FactionManager.faction_data[parent.faction].style
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
	var hair_texture = style.hair_styles[randi() % style.hair_styles.size()]
	var face_texture = style.faces[randi() % style.faces.size()]
	var head_image = hair_texture.get_image()
	head_image.blend_rect(face_texture.get_image(), Rect2i(0, 0, 64, 64), Vector2i(64, 64))
	var head_texture = ImageTexture.create_from_image(head_image)
	head_texture = get_texture_modified_skin(head_texture, skin_color, Color(0.933, 0.769, 0.6, 1.0))
	head_texture = get_texture_modified_skin(head_texture, hair_color, Color(0.133, 0.125, 0.208, 1.0))
	var nose_color = skin_color.darkened(0.5)
	nose_color.h -= 0.075
	head_texture = get_texture_modified_skin(head_texture, nose_color, Color("603535"))
	face_material.set("shader_parameter/base_texture", head_texture)
	var shirt_texture = style.shirts[randi() % style.shirts.size()]
	shirt_texture = get_texture_modified_skin(shirt_texture, skin_color, Color(0.933, 0.769, 0.6, 1.0))
	#var faction = 0
	#if "faction" in get_parent():
		#faction = get_parent().faction
	#if faction > 1:
		#var faction_color = FactionManager.faction_data[faction].color
		#shirt_texture = get_texture_modified_skin(shirt_texture, faction_color, Color(1.0, 0.0, 0.0, 1.0))
	#else:
		#shirt_texture = get_texture_modified_skin(shirt_texture, skin_color, Color(1.0, 0.0, 0.0, 1.0))
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
	current_style.skin_colors.clear()
	current_style.skin_colors.append(skin_color)
	current_style.hair_colors.clear()
	current_style.hair_colors.append(hair_color)
	current_style.hair_styles.clear()
	current_style.hair_styles.append(hair_texture)
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
			if (abs(c.r - target_color.r) < 0.01 and 
			abs(c.g - target_color.g) < 0.01 and 
			abs(c.b - target_color.b) < 0.01):
				img.set_pixel(x, y, replace_color)
	var new_texture = ImageTexture.create_from_image(img)
	return new_texture


func get_scalped() -> void:
	var face_material = cube.get_surface_override_material(0).duplicate()
	var head_image = BALD_HAIR.get_image()
	head_image.blend_rect(current_style.faces[0].get_image(), Rect2i(0, 0, 64, 64), Vector2i(64, 64))
	var head_texture = ImageTexture.create_from_image(head_image)
	head_texture = get_texture_modified_skin(head_texture, current_style.skin_colors[0], Color(0.933, 0.769, 0.6, 1.0))
	face_material.set("shader_parameter/base_texture", head_texture)
	cube.set_surface_override_material(0, face_material)
