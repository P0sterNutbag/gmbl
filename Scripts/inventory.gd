extends Control
class_name Inventory

enum modes {use, loot}
@export var mode = modes.use
@export var show_price: bool
var target = PlayerStats
var target2
@onready var item_container: VBoxContainer = %Items
@onready var title: Label = $MarginContainer/VBoxContainer/Label
@onready var money_label: Label = $MarginContainer/VBoxContainer/Label/Label2


func _ready():
	if show_price and "money" in target:
		money_label.show()
		money_label.text = "$" + str(target.money)
	else:
		money_label.hide()


func _process(delta: float) -> void:
	# take all
	if Input.is_action_just_pressed("reload") and mode == modes.loot:
		for item in item_container.get_children():
			for amount in item.amount:
				target.items.erase(item.item)
				target2.items.append(item.item)
				item_container.remove_child(item)
		get_parent().reset_inventories()


func set_items():
	var old_items: Array
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			child.queue_free()
	for item in target.items:
		if item is not Equipment:
			var same_items = item_container.get_children().filter(func(i): return i.text == item.title)
			if same_items.size() > 0:
				var same_item = same_items[0]
				same_item.amount += 1
				continue
		var inst = item_container.create_menu_item()
		inst.text = item.title
		inst.item = item
		if show_price:
			inst.price = item.price
		if mode == modes.use:
			inst.pressed.connect(item.use.bind(target))
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
	item_container.sort_menu_items()
	item_container.set_menu_item_focus()
	item_container.get_child(0).grab_focus()


func transfer_item(menu_item: Control):
	if show_price:
		if target2.money >= menu_item.item.price:
			target2.money -= menu_item.item.price
			target.money += menu_item.item.price
			get_parent().set_inventory_money()
		else:
			return
	target.items.erase(menu_item.item)
	item_container.remove_child(menu_item)
	target2.items.append(menu_item.item)
	if menu_item.item is Equipment:
		menu_item.item.equipped = false
	var inventory2
	if get_index() == 0:
		inventory2 = get_parent().get_child(1)
	else:
		inventory2 = get_parent().get_child(0)
	var inst = inventory2.item_container.create_menu_item()
	inst.text = menu_item.item.title
	inst.item = menu_item.item
	if show_price:
		inst.price = menu_item.item.price
	if mode == modes.use:
		inst.pressed.connect(menu_item.item.use.bind(target))
	elif mode == modes.loot:
		inst.pressed.connect(inventory2.transfer_item.bind(inst))
	menu_item.queue_free()
	inventory2.item_container.sort_menu_items()


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		set_items()
		if target is PlayerStats:
			title.text = "Inventory"
		else:
			title.text = target.title
