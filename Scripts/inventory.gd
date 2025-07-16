extends Control
class_name Inventory

enum modes {use, loot}
@export var mode = modes.use
@export var show_price: bool
var target = PlayerStats
var target2
@onready var item_container: MenuController = %Items
@onready var title: Label = $MarginContainer/VBoxContainer/Label
@onready var money_label: Label = $MarginContainer/VBoxContainer/Label/Label2


func _ready() -> void:
	if "money" in target:
		money_label.show()
		money_label.text = "$" + str(target.money)
	else:
		money_label.hide()


func _process(delta: float) -> void:
	if !visible or !get_parent().visible:
		return
	
	# take all
	if Input.is_action_just_pressed("reload") and mode == modes.loot:
		for item in item_container.get_children():
			for amount in item.amount:
				target.items.erase(item.item)
				target2.items.append(item.item)
				item_container.remove_child(item)
		get_parent().reset_inventories()
	
	# set money
	if money_label.visible and "money" in target:
		money_label.text = "$" + str(target.money)


func set_items():
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			item_container.remove_child(child)
			child.queue_free()
	var items: Array[Control]
	for item in target.items:
		if item is not Equipment:
			var same_items = items.filter(func(i): return i.text.containsn(item.title))
			if same_items.size() > 0:
				var same_item = same_items[0]
				same_item.amount += 1
				continue
		var inst = item_container.create_menu_item()
		items.append(inst)
		inst.text = item.title
		inst.resource = item
		if show_price:
			inst.price = item.price
		if mode == modes.use and item.usable:
			inst.pressed.connect(item.use.bind(target))
			if item.used_up.is_connected(on_use_item):
				item.used_up.disconnect(on_use_item)
			item.used_up.connect(on_use_item.bind(inst))
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
	if item_container.get_child_count() > 0:
		item_container.sort_menu_items()
		item_container.set_menu_item_focus()
		item_container.get_child(0).grab_focus()


func transfer_item(menu_item: Control):
	if show_price:
		if target2.money >= menu_item.resource.price:
			target2.money -= menu_item.resource.price
			target.money += menu_item.resource.price
			get_parent().set_inventory_money()
		else:
			var inventory2
			if get_index() == 0: inventory2 = get_parent().get_child(1)
			else: inventory2 = get_parent().get_child(0)
			inventory2.money_label.modulate = Color.RED
			var tween = create_tween()
			tween.tween_property(inventory2.money_label, "modulate", Color.WHITE, 1)
			return
	target.items.erase(menu_item.resource)
	item_container.remove_child(menu_item)
	if menu_item.resource is ItemMoney:
		PlayerStats.money += menu_item.resource.amount
		return
	target2.items.append(menu_item.resource)
	if menu_item.resource is Equipment:
		menu_item.resource.equipped = false
	get_parent().reset_inventories()
	#var inventory2
	#if get_index() == 0:
		#inventory2 = get_parent().get_child(1)
	#else:
		#inventory2 = get_parent().get_child(0)
	#var inst = inventory2.item_container.create_menu_item()
	#inst.text = menu_item.resource.title
	#inst.resource = menu_item.resource
	#if show_price:
		#inst.price = menu_item.resource.price
	#if mode == modes.use:
		#inst.pressed.connect(menu_item.resource.use.bind(target))
	#elif mode == modes.loot:
		#inst.pressed.connect(inventory2.transfer_item.bind(inst))
	#menu_item.queue_free()
	#inventory2.item_container.sort_menu_items()


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		set_items()
		if target is PlayerStats:
			title.text = "Inventory"
		else:
			title.text = target.title


func on_use_item(menu_item) -> void:
	if menu_item.get_index() == item_container.get_child_count() - 1:
		item_container.get_child(-2).grab_focus()
	menu_item.queue_free()
		
