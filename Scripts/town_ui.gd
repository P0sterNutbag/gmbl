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
@onready var player_model: Node3D = $PlayerPortrait/Offset/EnemyModel


func _enter_tree() -> void:
	Globals.ui = self
	UiController.close_all()


func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.hide()
	job_board.exit.connect(dialogue.leave_shop)


func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("ui_cancel"):
		if shop.visible:
			close_shop()
		if job_board.visible:
			UiController.close_interface(job_board)
			dialogue.leave_shop()
			UiController.open_interface(dialogue)



func start_dialogue(dialogue_data: DialogueTree, _shop: Shop = null) -> void:
	dialogue.shop = _shop
	#dialogue.show()
	dialogue.start_dialogue(dialogue_data)
	UiController.open_interface(dialogue)
	await get_tree().create_timer(0.05).timeout
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
	#if Input.get_connected_joypads().size() > 0:
		#shop_inventory2.grab_focus()
	UiController.open_interface(shop)


func close_shop() -> void:
	UiController.close_interface(shop)
	dialogue.leave_shop()


func _on_portrait_holder_visibility_changed() -> void:
	if !visible:
		return
	if !PlayerStats.gun:
		player_model.animation_player.play("IdleNoGun")
		return
	for child in player_model.gun_holder.get_children():
		if child.name == PlayerStats.gun.title:
			child.visible = true
			player_model.animation_player.play("Idle")
		else:
			child.visible = false
