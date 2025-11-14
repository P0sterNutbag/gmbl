extends CanvasLayer

var current_town: Town
@onready var town: PanelContainer = $Town
@onready var shop: HBoxContainer = $Shop
@onready var shop_inventory: PanelContainer = $Shop/Inventory
@onready var shop_inventory2: PanelContainer = $Shop/Inventory2
@onready var portraits: Control = $PortraitHolder
@onready var dialogue: VBoxContainer = $Dialogue
@onready var bounty_board: HBoxContainer = $BountyBoard


func _enter_tree() -> void:
	Globals.ui = self


func _ready() -> void:
	for child in get_children():
		child.hide()


#func _process(_delta: float) -> void:
	## opening things
	#if Input.is_action_just_pressed("inventory"):
		#inventory_holder.visible = !inventory_holder.visible
	#if Input.is_action_just_pressed("journal"):
		#if journal.visible:
			#journal.close()
		#else:
			#journal.open(PlayerStats.quests)
	
	# open pause menu
	#if Input.is_action_just_pressed("ui_cancel"):
		#if PlayerStats.state != PlayerStats.states.pause:
			#PauseMenu.activate()


func start_dialogue(dialogue_data: DialogueTree, _shop: Shop = null) -> void:
	dialogue.shop = _shop
	#dialogue.show()
	UiController.open_interface(dialogue)
	dialogue.start_dialogue(dialogue_data)
	portraits.show()


func enter_shop(shop_data: Shop) -> void:
	shop_inventory.target = PlayerStats.inventory
	shop_inventory.target2 = shop_data.inventory
	shop_inventory.show_price = true
	shop_inventory2.target = shop_data.inventory
	shop_inventory2.target2 = PlayerStats.inventory
	shop_inventory.show_price = true
	shop_inventory2.grab_focus()
	UiController.open_interface(shop)
	#shop.show()


#func _on_shop_visibility_changed() -> void:
	#portraits.visible = !shop.visible
