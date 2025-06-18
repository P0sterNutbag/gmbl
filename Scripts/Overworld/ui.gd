extends CanvasLayer

@onready var location_card: Control = $LocationCard
@onready var inventory_holder: HBoxContainer = $InventoryHolder
@onready var town: PanelContainer = $Town
@onready var shop: HBoxContainer = $Shop
@onready var shop_inventory: PanelContainer = $Shop/Inventory
@onready var shop_inventory2: PanelContainer = $Shop/Inventory2
@onready var portraits: HBoxContainer = $Portraits


func _enter_tree() -> void:
	Globals.ui = self


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		inventory_holder.visible = !inventory_holder.visible


func show_location_info(encounter: Node3D) -> void:
	location_card.show()
	location_card.target = encounter
	if encounter.show_title:
		location_card.title_value = encounter.title
	else:
		location_card.title_value = "???"
	if encounter.show_faction:
		location_card.faction_value = encounter.faction
	else:
		location_card.faction_value = "???"
	if encounter.show_difficulty:
		location_card.difficulty_value = encounter.difficulty
	else:
		location_card.difficulty_value = "???"
	if encounter.show_resources:
		location_card.resources_value = encounter.resources
	else:
		location_card.resources_value = "???"
	location_card.set_process(true)


func hide_location_info() -> void:
	location_card.hide()
	location_card.set_process(false)


func enter_shop(shop_data: Shop) -> void:
	shop_inventory.target = PlayerStats
	shop_inventory.target2 = shop_data
	shop_inventory2.target = shop_data
	shop_inventory2.target2 = PlayerStats
	shop_inventory2.grab_focus()
	shop.show()


func _on_shop_visibility_changed() -> void:
	portraits.visible = shop.visible
