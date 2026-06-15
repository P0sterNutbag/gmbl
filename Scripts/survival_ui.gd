extends CanvasLayer

var demo_message: Control
var menu_buttons_has_mouse: bool
@onready var player_inventory_holder: HBoxContainer = $Menus/VBoxContainer/PlayerInventory
@onready var player_inventory = $Menus/VBoxContainer/PlayerInventory/Inventory
@onready var transfer_inventory_holder: VBoxContainer = $TransferInventory
@onready var player_transfer_inventory: InventoryUI = %Inventory
@onready var loot_transfer_inventory: InventoryUI = %Inventory2
@onready var journal: Control = $Menus/VBoxContainer/Journal
@onready var compass: Control = $Compass
@onready var pause_menu: Control = $PauseMenu
@onready var progress_menu: PanelContainer = $ProgressMenu
@onready var death_menu: PanelContainer = $DeathMenu
@onready var menu_holder: Control = $Menus
@onready var factions: PanelContainer = $Menus/VBoxContainer/Factions
@onready var log_box: VBoxContainer = %Log
@onready var player_hp_bar: ProgressBar = %ProgressBar
@onready var menu_buttons: Control = $MenuButtons
@onready var skills_menu: Control = %Skills
@onready var squad: Control = $Menus/VBoxContainer/Squad
const LOG_NOTIFICATION = preload("res://Scenes/UI/log_notification.tscn")


func _enter_tree() -> void:
	Globals.survival_ui = self
	await get_tree().process_frame
	if Globals.overworld and Globals.overworld == get_tree().current_scene:
		menu_buttons.show()
	else:
		menu_buttons.hide()


func _ready() -> void:
	SaveController.save.connect(_on_game_saved)
	UiController.ui_opened.connect(_on_ui_opened)
	UiController.ui_closed.connect(_on_ui_closed)
	tree_exited.connect(_on_tree_exited)
	demo_message = get_node_or_null("DemoMessage")


func _process(_delta: float) -> void:
	# opening things
	if Input.is_action_just_pressed("inventory"):
		if transfer_inventory_holder.visible:
			UiController.close_interface(transfer_inventory_holder)
			return
		if !menu_holder.visible:
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
		else:
			UiController.close_interface(journal)
	if Input.is_action_just_pressed("close"):
		if !pause_menu.visible and PlayerStats.state != PlayerStats.states.dead:
			if UiController.is_canvas_layer_open(self):
				UiController.close_all()
				return
			if UiController.is_canvas_layer_open(Globals.ui):
				return
	if Input.is_action_just_pressed("pause") and PlayerStats.state != PlayerStats.states.dead:
		if !menu_holder.visible and !pause_menu.visible:
			if !demo_message or !demo_message.visible:
				UiController.open_interface(pause_menu)
		elif pause_menu.visible and pause_menu.pause_menu.visible:
			UiController.close_interface()
		elif menu_holder.visible:
			UiController.close_interface()
	# compass
	var compass_item = PlayerStats.inventory.find_item("compass")
	if compass_item and compass_item.equipped:
		compass.visible = true
	else:
		compass.visible = false
	
	#if Input.is_action_pressed("light") and Input.is_action_just_pressed("aim"):
		#if visible:
			#hide()
		#else:
			#show()
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


func _on_pause_pressed() -> void:
	if pause_menu.visible:
		UiController.close_interface(pause_menu)
	else:
		UiController.open_interface(pause_menu)


func _on_ui_opened() -> void:
	if UiController.current_ui.get_parent().get_parent() == menu_holder:
		menu_holder.show()
	else:
		menu_holder.hide()


func _on_ui_closed(closed_node: Control) -> void:
	if closed_node and closed_node.get_parent().get_parent() == menu_holder:
		menu_holder.hide()


func _on_inventory_button_pressed() -> void:
	UiController.open_interface(player_inventory_holder)


func _on_journal_button_pressed() -> void:
	UiController.open_interface(journal)


func _on_faction_button_pressed() -> void:
	UiController.open_interface(factions)


func _on_squad_tab_pressed() -> void:
	UiController.open_interface(squad)


func _on_menu_buttons_mouse_entered() -> void:
	menu_buttons_has_mouse = true


func _on_menu_buttons_mouse_exited() -> void:
	menu_buttons_has_mouse = false


func _on_tree_exited() -> void:
	for child in log_box.get_children():
		child.queue_free()
