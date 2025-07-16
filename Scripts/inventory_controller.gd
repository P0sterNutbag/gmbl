extends HBoxContainer

signal exit


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	resized.connect(_on_resized)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and visible:
		clear_inventories()
		hide()
		exit.emit()
	if get_child_count() > 1:
		if Input.is_action_just_pressed("ui_right"):
			var inventory = get_child(1)
			inventory.item_container.select_last_button()
		elif Input.is_action_just_pressed("ui_left"):
			var inventory = get_child(0)
			inventory.item_container.select_last_button()


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


func _on_visibility_changed() -> void:
	if visible:
		get_child(get_child_count()-1).grab_focus()


func _on_resized() -> void:
	for child in get_children():
		child.size = size
