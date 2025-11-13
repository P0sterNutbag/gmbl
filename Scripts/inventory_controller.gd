extends HBoxContainer

signal exit


func _ready() -> void:
	resized.connect(_on_resized)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and visible:
		clear_inventories()
		UiController.close_interface(self)
		exit.emit()
	if get_child_count() > 1:
		if Input.is_action_just_pressed("ui_right"):
			var inventory = get_child(1)
			inventory.item_container.select_last_button()
			get_child(0).stats_panel.hide()
		elif Input.is_action_just_pressed("ui_left"):
			var inventory = get_child(0)
			inventory.item_container.select_last_button()
			get_child(1).stats_panel.hide()


func open(shop: Shop) -> void:
	Globals.ui.start_dialogue(shop.dialogue, shop)


func reset_inventories() -> void:
	for child in get_children():
		child.set_items()


func clear_inventories() -> void:
	for child in get_children():
		child.item_container.delete_children()


func set_inventory_money() -> void:
	for child in get_children():
		child.money_label.text = "$" + str(child.target.money)


func _on_resized() -> void:
	for child in get_children():
		child.size = size


func close() -> void:
	hide()
	clear_inventories()
	exit.emit()
