extends Node
const starting_gear = preload("uid://dpjy0ettwaiyp")
@onready var inventories: Control = $CanvasLayer/Inventories
@onready var cosmetics: PanelContainer = $CanvasLayer/Inventories/VBoxContainer/HBoxContainer/Cosmetics
@onready var starting_inventory: InventoryUI = %Inventory
@onready var player_inventory: InventoryUI = %Inventory2
@onready var node_3d: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var player_model: Node3D = $EnemyModel
@onready var appearance_options: VBoxContainer = $CanvasLayer/Inventories/VBoxContainer/HBoxContainer/Cosmetics/MarginContainer/VBoxContainer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var saved_gear
	if ResourceLoader.exists("user://starting_gear.res"):
		saved_gear = ResourceLoader.load("user://starting_gear.res")
	else:
		saved_gear = starting_gear.duplicate(true)
	starting_inventory.source_inventory = saved_gear
	player_inventory.source_inventory = PlayerStats.inventory
	starting_inventory.target_inventory = player_inventory.source_inventory
	player_inventory.target_inventory = starting_inventory.source_inventory
	starting_inventory.set_items()
	player_inventory.set_items()


func _process(_delta: float) -> void:
	if PlayerStats.guns.size() <= 0:
		animation_player.play("IdleNoGun")
		for node in node_3d.get_children():
			node.visible = false
		return
	animation_player.play("Idle")
	for node in node_3d.get_children():
		var gun = PlayerStats.guns[0]
		node.visible = gun and node.name == gun.resource_name


func _on_menu_button_pressed() -> void:
	#inventories.hide()
	#UiController.open_interface(cosmetics)
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn")


func _on_face_button_option_changed(resource: Variant) -> void:
	var faces: Array = player_model.style_data.faces
	set_player_style(faces, resource)


func _on_shirt_options_option_changed(resource: Variant) -> void:
	var shirts: Array = player_model.style_data.shirts
	set_player_style(shirts, resource)


func _on_pants_options_option_changed(resource: Variant) -> void:
	var pants: Array = player_model.style_data.pants_colors
	set_player_style(pants, resource.color)


func _on_shoes_options_option_changed(resource: Variant) -> void:
	var shoes: Array = player_model.style_data.shoe_colors
	set_player_style(shoes, resource.color)


func set_player_style(array: Array, new_resource) -> void:
	array.clear()
	array.append(new_resource)
	player_model.set_materials()


func _on_skin_options_option_changed(resource: Variant) -> void:
	var skin: Array = player_model.style_data.skin_colors
	set_player_style(skin, resource.color)
	#var material: Material = player_model.cube.get_surface_override_material(0)
	#var texture: Texture2D = material.get("shader_parameter/base_texture")
	#var img := texture.get_image().duplicate()
	#var target_color = img.get_pixel(img.get_height()-1, img.get_width()-1)
	#var replace_color = resource.color
	#for x in img.get_width():
		#for y in img.get_height():
			#var c = img.get_pixel(x, y)
			#if c.is_equal_approx(target_color):
				#img.set_pixel(x, y, replace_color)
	#var new_texture = ImageTexture.create_from_image(img)
	#material.set("shader_parameter/base_texture", new_texture)
