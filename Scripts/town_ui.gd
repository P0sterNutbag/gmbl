extends CanvasLayer

var current_town: Town
@onready var location_card: Control = $LocationCard
@onready var inventory_holder: HBoxContainer = $InventoryHolder
@onready var town: PanelContainer = $Town
@onready var shop: HBoxContainer = $Shop
@onready var shop_inventory: PanelContainer = $Shop/Inventory
@onready var shop_inventory2: PanelContainer = $Shop/Inventory2
#@onready var portraits: HBoxContainer = $Portraits
@onready var dialogue: VBoxContainer = $Dialogue
@onready var bounty_board: HBoxContainer = $BountyBoard
@onready var journal: MenuList = $Journal


func _enter_tree() -> void:
	Globals.ui = self
	if location_card:
		hide_location_info()
	
func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("inventory"):
		inventory_holder.visible = !inventory_holder.visible
	if Input.is_action_just_pressed("journal"):
		if journal.visible:
			journal.close()
		else:
			journal.open(PlayerStats.quests)
	
	# open pause menu
	#if Input.is_action_just_pressed("ui_cancel"):
		#if PlayerStats.state != PlayerStats.states.pause:
			#PauseMenu.activate()


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


func start_dialogue(dialogue_data: DialogueTree, shop: Shop = null) -> void:
	dialogue.shop = shop
	dialogue.show()
	dialogue.start_dialogue(dialogue_data)


func enter_shop(shop_data: Shop) -> void:
	shop_inventory.target = PlayerStats
	shop_inventory.target2 = shop_data
	shop_inventory2.target = shop_data
	shop_inventory2.target2 = PlayerStats
	shop_inventory2.grab_focus()
	shop.show()


#func _on_shop_visibility_changed() -> void:
	#portraits.visible = !shop.visible
