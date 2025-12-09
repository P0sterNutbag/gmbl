extends CanvasLayer

var current_town: Town
@onready var town: PanelContainer = $Town
@onready var shop: HBoxContainer = $Shop
@onready var shop_inventory: PanelContainer = $Shop/Inventory
@onready var shop_inventory2: PanelContainer = $Shop/Inventory2
@onready var portraits: Control = $PortraitHolder
@onready var dialogue: VBoxContainer = $Dialogue
@onready var job_board: HBoxContainer = $JobBoard
@onready var npc_portrait_model: Node3D = $ShopkeeperPortrait/Offset/EnemyModel
@onready var repair_menu: PanelContainer = $Repair


func _enter_tree() -> void:
	Globals.ui = self


func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.hide()


func _process(_delta: float) -> void:
	# opening things
	if shop.visible and Input.is_action_just_pressed("ui_cancel"):
		close_shop()


func start_dialogue(dialogue_data: DialogueTree, _shop: Shop = null) -> void:
	dialogue.shop = _shop
	#dialogue.show()
	UiController.open_interface(dialogue)
	dialogue.start_dialogue(dialogue_data)
	portraits.show()


func enter_shop(shop_data: Shop) -> void:
	shop_inventory.source_inventory = PlayerStats.inventory
	shop_inventory.target_inventory = shop_data.inventory
	shop_inventory.show_price = true
	shop_inventory.set_items()
	shop_inventory2.source_inventory = shop_data.inventory
	shop_inventory2.target_inventory = PlayerStats.inventory
	shop_inventory2.shop = shop_data
	shop_inventory2.show_price = true
	shop_inventory2.set_items()
	shop_inventory2.grab_focus()
	UiController.open_interface(shop)


func close_shop() -> void:
	UiController.close_interface(shop)
	dialogue.leave_shop()
