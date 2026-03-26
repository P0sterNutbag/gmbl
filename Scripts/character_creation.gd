extends Node

var mouse_velocity: Vector2
const starting_gear = preload("uid://dpjy0ettwaiyp")
@onready var cosmetics: PanelContainer = %Cosmetics
@onready var skills: PanelContainer = %Skills
@onready var starting_inventory: InventoryUI = %Inventory
@onready var player_inventory: InventoryUI = %Inventory2
@onready var node_3d: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var player_model: Node3D = $EnemyModel
@onready var appearance_options: VBoxContainer = %Cosmetics/MarginContainer/VBoxContainer
@onready var camera_3d: Camera3D = $Camera3D
@onready var skin_options: Button = %Cosmetics/MarginContainer/VBoxContainer/SkinOptions
@onready var hair_color_options: Button = %Cosmetics/MarginContainer/VBoxContainer/HairColorOptions
@onready var hair_options: Button = %Cosmetics/MarginContainer/VBoxContainer/HairOptions
@onready var face_options: Button = %Cosmetics/MarginContainer/VBoxContainer/FaceOptions
@onready var shirt_options: Button = %Cosmetics/MarginContainer/VBoxContainer/ShirtOptions
@onready var pants_options: Button = %Cosmetics/MarginContainer/VBoxContainer/PantsOptions
@onready var shoes_options: Button = %Cosmetics/MarginContainer/VBoxContainer/ShoesOptions


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	PlayerStats.reset_stats()
	skills.setup()
	# get starting gear
	var saved_gear
	if ResourceLoader.exists("user://starting_gear.res"):
		saved_gear = ResourceLoader.load("user://starting_gear.res")
	else:
		saved_gear = starting_gear.duplicate(true)
	starting_inventory.hide()
	player_inventory.hide()
	starting_inventory.source_inventory = saved_gear
	player_inventory.source_inventory = PlayerStats.inventory
	starting_inventory.target_inventory = player_inventory.source_inventory
	player_inventory.target_inventory = starting_inventory.source_inventory
	starting_inventory.show()
	player_inventory.show()
	# get starting money
	var starting_money = 200
	if ResourceLoader.exists("user://progress_data.res"):
		var progress_data = ResourceLoader.load("user://progress_data.res")
		starting_money = progress_data.starting_money
	PlayerStats.inventory.money = starting_money


func _process(delta: float) -> void:
	# move camera
	camera_3d.position.y = lerp(camera_3d.position.y, 1.3, delta)
	# spin character
	player_model.rotate_y(mouse_velocity.x * delta * 0.01)
	mouse_velocity = lerp(mouse_velocity, Vector2.ZERO, delta * 10)
	# set gun and animation
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
	SaveController.delete_save_data()
	SceneManager.save_on_enter = true
	PlayerStats.player_style = player_model.style_data.duplicate()
	if Globals.overworld:
		SceneManager.start_scene_transition(Globals.overworld)
	else:
		SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn")


func _on_face_button_option_changed(value: Variant) -> void:
	var faces: Array = player_model.style_data.faces
	set_player_style(faces, value)


func _on_shirt_options_option_changed(value: Variant) -> void:
	var shirts: Array = player_model.style_data.shirts
	set_player_style(shirts, value)


func _on_pants_options_option_changed(value: Variant) -> void:
	var pants: Array = player_model.style_data.pants_colors
	set_player_style(pants, value)


func _on_shoes_options_option_changed(value: Variant) -> void:
	var shoes: Array = player_model.style_data.shoe_colors
	set_player_style(shoes, value)


func set_player_style(array: Array, new_resource) -> void:
	array.clear()
	array.append(new_resource)
	player_model.set_materials()


func _on_skin_options_option_changed(value: Variant) -> void:
	var skin: Array = player_model.style_data.skin_colors
	set_player_style(skin, value)


func _on_back_button_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/main_menu.tscn")


func _on_hair_color_options_option_changed(value: Variant) -> void:
	var hair_colors: Array = player_model.style_data.hair_colors
	set_player_style(hair_colors, value)


func _on_hair_options_option_changed(value: Variant) -> void:
	var hair_styles: Array = player_model.style_data.hair_styles
	set_player_style(hair_styles, value)


func _on_randomize_button_pressed() -> void:
	var skin = skin_options.get_random_option()
	player_model.style_data.skin_colors.clear()
	player_model.style_data.skin_colors.append(skin)
	var hair_color = hair_color_options.get_random_option()
	player_model.style_data.hair_colors.clear()
	player_model.style_data.hair_colors.append(hair_color)
	var hair = hair_options.get_random_option()
	player_model.style_data.hair_styles.clear()
	player_model.style_data.hair_styles.append(hair)
	var face = face_options.get_random_option()
	player_model.style_data.faces.clear()
	player_model.style_data.faces.append(face)
	var shirt = shirt_options.get_random_option()
	player_model.style_data.shirts.clear()
	player_model.style_data.shirts.append(shirt)
	var pant = pants_options.get_random_option()
	player_model.style_data.pants_colors.clear()
	player_model.style_data.pants_colors.append(pant)
	var shoe_color = shoes_options.get_random_option()
	player_model.style_data.shoe_colors.clear()
	player_model.style_data.shoe_colors.append(shoe_color)
	player_model.set_materials()


func _on_spin_character_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("shoot"):
		mouse_velocity = Input.get_last_mouse_velocity()


func _on_line_edit_text_changed(new_text: String) -> void:
	PlayerStats.player_name = new_text
