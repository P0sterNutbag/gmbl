extends CanvasLayer

@onready var player_inventory_holder: HBoxContainer = $PlayerInventory
@onready var transfer_inventory_holder: HBoxContainer = $TransferInventory
@onready var player_transfer_inventory: InventoryUI = %Inventory
@onready var loot_transfer_inventory: InventoryUI = %Inventory2
@onready var journal: HBoxContainer = $Journal
@onready var compass: Control = $TopCenter/Compass
@onready var pause_menu: Control = $PauseMenu
@onready var player_inventory: InventoryUI = $PlayerInventory/Inventory
@onready var progress_menu: PanelContainer = $ProgressMenu
@onready var death_menu: PanelContainer = $DeathMenu
@onready var stats_anchor: Control = $StatsAnchor


func _enter_tree() -> void:
	Globals.survival_ui = self
	await get_tree().process_frame
	if Globals.overworld and Globals.overworld == get_tree().current_scene:
		stats_anchor.show()
		stats_anchor.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		stats_anchor.hide()
		stats_anchor.process_mode = Node.PROCESS_MODE_DISABLED


#func _ready() -> void:
	#for child in get_children():
		#child.hide()


func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("inventory"):
		if !player_inventory_holder.visible:
			if UiController.is_canvas_layer_open(Globals.ui) or PlayerStats.state != PlayerStats.states.walk:
				return
			player_inventory_holder.get_child(0).source_inventory = PlayerStats.inventory
			UiController.open_interface(player_inventory_holder)
		else:
			UiController.close_interface(player_inventory_holder)
	if Input.is_action_just_pressed("journal"):
		if !journal.visible:
			if UiController.is_canvas_layer_open(Globals.ui):
				return
			UiController.open_interface(journal)
			journal.open(PlayerStats.quests)
		else:
			UiController.close_interface(journal)
	if Input.is_action_just_pressed("ui_cancel"):
		if !pause_menu.visible:
			if UiController.is_canvas_layer_open(self):
				UiController.close_all()
				return
			if UiController.is_canvas_layer_open(Globals.ui):
				return
	if Input.is_action_just_pressed("pause"):
		if !pause_menu.visible:
			UiController.open_interface(pause_menu)
		else:
			UiController.close_interface(pause_menu)
	
	# compass
	var compass_item = PlayerStats.inventory.find_item("compass")
	if compass_item and compass_item.equipped:
		compass.visible = true
	else:
		compass.visible = false
	
	# overworld health and status effects
	if Globals.overworld == get_tree().current_scene:
		stats_anchor.global_position.y = Globals.player.camera.unproject_position(Globals.player.hud_anchor.global_position).y
		stats_anchor.global_position.y -= stats_anchor.size.y
	
	if UiController.current_ui:
		if stats_anchor.visible:
			stats_anchor.hide()
	elif stats_anchor.process_mode == PROCESS_MODE_INHERIT:
		stats_anchor.show()
	
	# open pause menu
	#if Input.is_action_just_pressed("ui_cancel"):
		#if PlayerStats.state != PlayerStats.states.pause:
			#Globals.pause_game()


#func open_menu(menu: Control, array: Array = []) -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	#menu.show()
	#if menu is MenuList:
		#menu.open(array)
	#PlayerStats.change_state(PlayerStats.states.pause)
#
#
#func close_menu(menu: Control) -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#menu.hide()
	#PlayerStats.change_state(PlayerStats.states.walk)


func loot(target: Inventory) -> void:
	player_transfer_inventory.mode = player_transfer_inventory.modes.loot
	loot_transfer_inventory.mode = loot_transfer_inventory.modes.loot
	player_transfer_inventory.source_inventory = PlayerStats.inventory
	player_transfer_inventory.target_inventory = target
	loot_transfer_inventory.source_inventory = target
	loot_transfer_inventory.target_inventory = PlayerStats.inventory
	if Input.get_connected_joypads().size() > 0:
		loot_transfer_inventory.grab_focus()
	player_transfer_inventory.show_price = false
	loot_transfer_inventory.show_price = false
	UiController.open_interface(transfer_inventory_holder)


func close_inventory() -> void:
	UiController.close_interface(player_inventory_holder)


func close_transfer_inventory() -> void:
	UiController.close_interface(transfer_inventory_holder)


func hide_all_ui() -> void:
	for child in get_children():
		child.hide()


func show_ui() -> void:
	get_child(0).show()
	get_child(1).show()

#func _on_menu_exit() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#PlayerStats.change_state(PlayerStats.states.walk)
