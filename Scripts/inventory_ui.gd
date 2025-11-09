extends Control
class_name InventoryUI

enum modes {use, loot}
@export var mode = modes.use
@export var show_price: bool
var target = PlayerStats
var target2
const text_style = preload("res://Art/Themes/text.tres")
@onready var item_container: MenuController = %Items
@onready var title: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var money_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label2
@onready var size_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label3
@onready var stats: HBoxContainer = %Stats
@onready var stats_panel: PanelContainer = $MarginContainer/VBoxContainer/Panel
@onready var description: Label = %Label


func _ready() -> void:
	if "money" in target:
		money_label.show()
		money_label.text = "$" + str(target.money)
	else:
		money_label.hide()


func _process(_delta: float) -> void:
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
	
	# set size
	if "inventory" in target:
		var space_left = target.inventory.get_space_left()
		size_label.text = str(target.inventory.space - space_left) + "/" + str(target.inventory.space)


func set_items():
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			item_container.remove_child(child)
			child.queue_free()
	var items: Array[Control]
	for item in target.items:
		#if item.stackable:
			#var same_items = items.filter(func(i): return i.text.containsn(item.title))
			#if same_items.size() > 0:
				#var same_item = same_items[0]
				#same_item.resource.amount += 1
				#same_item.amount += 1
				#continue
		var inst = item_container.create_menu_item()
		items.append(inst)
		inst.text = item.title
		inst.resource = item
		inst.amount = item.amount
		inst.owner = self
		inst.moveable = true
		if show_price:
			inst.price = item.price
			if item is EquipmentGun:
				inst.price = round(inst.price * item.condition / 100)
		inst.focus_entered.connect(set_description.bind(item))
		inst.delete.connect(target.items.erase.bind(inst.resource))
		inst.delete.connect(set_items)
		inst.transfer.connect(transfer_item.bind(inst))
		if mode == modes.use:
			if item is ItemUsable:
				item.target_node = target
				if item.used_up.is_connected(on_use_item):
					item.used_up.disconnect(on_use_item)
				item.used_up.connect(on_use_item.bind(inst))
				if !item.used_up.is_connected(target.items.erase):
					item.used_up.connect(target.items.erase.bind(item))
			inst.pressed.connect(item.on_pressed)
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
	if item_container.get_child_count() > 0:
		item_container.sort_menu_items()
		item_container.set_menu_item_focus()
		item_container.get_child(0).grab_focus()


func transfer_item(menu_item: Control):
	var item = menu_item.resource
	# check space
	if "inventory" in target2:
		if target2.inventory.get_space_left(item) <= 0 and item.takes_space:
			return
	# determine other inventory
	var inventory2
	if get_index() == 0: 
		inventory2 = get_parent().get_child(1)
	else: 
		inventory2 = get_parent().get_child(0)
	# check money
	if show_price:
		if target2.money >= menu_item.resource.price:
			target2.money -= menu_item.resource.price
			target.money += menu_item.resource.price
			get_parent().set_inventory_money()
		else:
			inventory2.money_label.modulate = Color.RED
			var tween = create_tween()
			tween.tween_property(inventory2.money_label, "modulate", Color.WHITE, 1)
			return
	var amount_to_move = 1
	if Input.is_action_pressed("shift"):
		amount_to_move = item.amount
	item.amount -= amount_to_move
	if item.amount <= 0:
		target.items.erase(item)
	if item is ItemMoney:
		PlayerStats.money += item.amount
		return
	if item is ItemBundle:
		for i in item.items:
			target2.items.append(i)
	else:
		var same_item = Globals.find_item(target2.items, item.title)
		if same_item:
			same_item.amount += amount_to_move
		else:
			var new_item = item.duplicate()
			new_item.amount = amount_to_move
			target2.items.append(new_item)
	if item is Equipment:
		item.equipped = false
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


func set_description(item: Item):
	for child in stats.get_children():
		child.queue_free()
	if item.description != "":
		description.show()
		description.text = item.description
	else:
		description.hide()
	if item is not Equipment and item.description == "":
		stats_panel.hide()
		return
	if item is not EquipmentGun:
		return
	stats_panel.show()
	for stat in item.stats:
		var inst = Label.new()
		#inst.text = stat + ": " + str(item.stats[stat])
		#inst.text = stat + ": " + str(item.get("gun_stats").condition) + "/" + str(item.get("gun_stats").max_condition)
		inst.text = stat + ": " + str(item.get(item.stats[stat]))
		inst.theme = text_style
		stats.add_child(inst)


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		set_items()
		if target is PlayerStats:
			title.text = "Inventory"
		else:
			title.text = target.title


func on_use_item(menu_item) -> void:
	if !menu_item:
		return
	var item = menu_item.resource
	item.amount -= 1
	if item.amount <= 0:
		if menu_item.get_index() == item_container.get_child_count() - 1:
			item_container.get_child(-2).grab_focus()
		menu_item.queue_free()
