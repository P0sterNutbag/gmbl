extends CanvasLayer

@onready var player_inventory_holder: HBoxContainer = $Menus/VBoxContainer/PlayerInventory
@onready var player_inventory = $Menus/VBoxContainer/PlayerInventory/Inventory
@onready var transfer_inventory_holder: HBoxContainer = $TransferInventory
@onready var player_transfer_inventory: InventoryUI = %Inventory
@onready var loot_transfer_inventory: InventoryUI = %Inventory2
@onready var journal: Control = $Menus/VBoxContainer/Journal
@onready var compass: Control = $TopCenter/Compass
@onready var pause_menu: Control = $PauseMenu
@onready var progress_menu: PanelContainer = $ProgressMenu
@onready var death_menu: PanelContainer = $DeathMenu
@onready var stats_anchor: Control = $StatsAnchor
@onready var menu_holder: Control = $Menus
@onready var factions: PanelContainer = $Menus/VBoxContainer/Factions
@onready var log_box: VBoxContainer = %Log
@onready var player_hp_bar: ProgressBar = %ProgressBar
const LOG_NOTIFICATION = preload("res://Scenes/UI/log_notification.tscn")


func _enter_tree() -> void:
	Globals.survival_ui = self
	await get_tree().process_frame
	if Globals.overworld and Globals.overworld == get_tree().current_scene:
		stats_anchor.show()
		stats_anchor.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		stats_anchor.hide()
		stats_anchor.process_mode = Node.PROCESS_MODE_DISABLED


func _ready() -> void:
	SaveController.save.connect(_on_game_saved)


func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("inventory"):
		if !menu_holder.visible:
			if UiController.is_canvas_layer_open(Globals.ui) or PlayerStats.state != PlayerStats.states.walk:
				return
			player_inventory_holder.get_child(0).source_inventory = PlayerStats.inventory
			menu_holder.show()
			UiController.open_interface(player_inventory_holder)
		else:
			menu_holder.hide()
			UiController.close_interface(player_inventory_holder)
		if transfer_inventory_holder.visible:
			UiController.close_interface(transfer_inventory_holder)
	if Input.is_action_just_pressed("journal"):
		if !journal.visible:
			if UiController.is_canvas_layer_open(Globals.ui):
				return
			menu_holder.show()
			UiController.open_interface(journal)
			journal.open(PlayerStats.quests)
		else:
			menu_holder.hide()
			UiController.close_interface(journal)
	if Input.is_action_just_pressed("ui_cancel"):
		if !pause_menu.visible and PlayerStats.state != PlayerStats.states.dead:
			if UiController.is_canvas_layer_open(self):
				menu_holder.hide()
				UiController.close_all()
				return
			if UiController.is_canvas_layer_open(Globals.ui):
				return
	if Input.is_action_just_pressed("pause") and PlayerStats.state != PlayerStats.states.dead:
		if !pause_menu.visible:
			menu_holder.hide()
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
	#if Globals.overworld == get_tree().current_scene:
		#stats_anchor.global_position.y = Globals.player.camera.unproject_position(Globals.player.hud_anchor.global_position).y
		#stats_anchor.global_position.y -= stats_anchor.size.y
	#if UiController.current_ui:
		#if stats_anchor.visible:
			#stats_anchor.hide()
	#elif stats_anchor.process_mode == PROCESS_MODE_INHERIT:
		#stats_anchor.show()


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


func create_notification(notification_text: String) -> void:
	var inst = LOG_NOTIFICATION.instantiate()
	log_box.add_child(inst)
	#log_box.move_child(inst, 1)
	inst.text = notification_text
	var tween = create_tween()
	tween.tween_interval(3)
	tween.tween_property(inst, "modulate:a", 0.0, 1)
	tween.tween_callback(inst.queue_free)


func close_inventory() -> void:
	UiController.close_interface(player_inventory_holder)


func close_transfer_inventory() -> void:
	UiController.close_interface(transfer_inventory_holder)


func hide_all_ui() -> void:
	for child in get_children():
		if child.process_mode == PROCESS_MODE_INHERIT:
			child.hide()


func show_ui() -> void:
	get_child(0).show()
	get_child(1).show()


func _on_inventory_tab_pressed() -> void:
	UiController.open_interface(player_inventory_holder)


func _on_journal_tab_pressed() -> void:
	UiController.open_interface(journal)


func _on_exit_menu_pressed() -> void:
	UiController.close_all()
	menu_holder.hide()


func _on_faction_tab_pressed() -> void:
	UiController.open_interface(factions)


func _on_game_saved() -> void:
	create_notification("Game saved")
