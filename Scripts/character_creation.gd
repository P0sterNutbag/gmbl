extends Node

@onready var inventories: Control = $CanvasLayer/Inventories
@onready var cosmetics: PanelContainer = $CanvasLayer/Inventories/VBoxContainer/HBoxContainer/Cosmetics
@onready var starting_inventory: InventoryUI = %Inventory
@onready var player_inventory: InventoryUI = %Inventory2
@onready var node_3d: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var player_model: Node3D = $EnemyModel


func _ready() -> void:
	player_inventory.source_inventory = PlayerStats.inventory
	starting_inventory.target_inventory = player_inventory.source_inventory
	player_inventory.target_inventory = starting_inventory.source_inventory


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
	faces.clear()
	faces.append(resource)
	player_model.set_materials()


func _on_shirt_options_option_changed(resource: Variant) -> void:
	var shirts: Array = player_model.style_data.shirts
	shirts.clear()
	shirts.append(resource)
	player_model.set_materials()


func _on_pants_options_option_changed(resource: Variant) -> void:
	var pants: Array = player_model.style_data.pants_colors
	pants.clear()
	pants.append(resource.colors[0])
	player_model.set_materials()


func _on_shoes_options_option_changed(resource: Variant) -> void:
	var shoes: Array = player_model.style_data.shoe_colors
	shoes.clear()
	shoes.append(resource.colors[0])
	player_model.set_materials()
