extends CanvasLayer

var current_town: Town
var current_shop: TownOption
@onready var town: PanelContainer = $Town
@onready var shop: VBoxContainer = $Shop
@onready var shop_inventory: PanelContainer = %Inventory
@onready var shop_inventory2: PanelContainer = %Inventory2
@onready var portraits: Control = $PortraitHolder
@onready var dialogue: VBoxContainer = $Dialogue
@onready var job_board: Control = $JobBoard
@onready var npc_portrait_model: Node3D = $ShopkeeperPortrait/Offset/EnemyModel
@onready var repair_menu: Control = $Repair
@onready var player_model: Node3D = $PlayerPortrait/Offset/EnemyModel
@onready var player_name: Label = $PortraitHolder/HBoxContainer/PlayerName
@onready var bounty_viewport: SubViewport = $BountyPicture
@onready var item_preferences: VBoxContainer = %ItemPreferences
@onready var preferences_holder: Control = %PreferenceHolder
@onready var poi_menu: PanelContainer = $PoiMenu
@onready var empty_poi_menu: PanelContainer = $EmptyPoiMenu


func _enter_tree() -> void:
	Globals.ui = self
	UiController.close_all(false)


func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.hide()
	job_board.exit.connect(dialogue.leave_shop)
	player_name.text = PlayerStats.player_name


func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("close"):
		if shop.visible:
			close_shop()
		elif job_board.visible:
			UiController.close_interface(job_board)
			dialogue.leave_shop()
			UiController.open_interface(dialogue)
		elif poi_menu.visible:
			UiController.close_interface(poi_menu)


func start_dialogue(dialogue_data: DialogueTree, _shop: TownOption = null) -> void:
	dialogue.shop = _shop
	#dialogue.show()
	dialogue.start_dialogue(dialogue_data)
	UiController.open_interface(dialogue)
	await get_tree().create_timer(0.05).timeout


func enter_shop(shop_data: Shop) -> void:
	current_shop = shop_data
	shop_inventory.source_inventory = PlayerStats.inventory
	shop_inventory.target_inventory = shop_data.inventory
	shop_inventory.show_price = shop_data.uses_money
	shop_inventory.set_items()
	shop_inventory2.source_inventory = shop_data.inventory
	shop_inventory2.target_inventory = PlayerStats.inventory
	shop_inventory2.shop = shop_data
	shop_inventory2.show_price = shop_data.uses_money
	shop_inventory2.set_items()
	#if Input.get_connected_joypads().size() > 0:
		#shop_inventory2.grab_focus()
	UiController.open_interface(shop)
	if shop_data.uses_money:
		preferences_holder.show()
		for child in item_preferences.get_children():
			if child is not TextureRect:
				continue
			var modifier = shop_data.price_modifiers[child.name]
			if modifier >= 0.75:
				child.show()
			else:
				child.hide()
	else:
		preferences_holder.hide()


func close_shop() -> void:
	UiController.close_interface(shop, false)
	if current_shop.dialogue or Globals.overworld.current_encounter.friendly_dialogue_tree:
		dialogue.leave_shop()
	else:
		await get_tree().process_frame
		UiController.open_interface(Globals.ui.town)#.re_enter_town()


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


func _on_dialogue_visibility_changed() -> void:
	portraits.visible = dialogue.visible
