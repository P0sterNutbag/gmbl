extends Control
class_name InventoryUI

enum modes {use, loot}
@export var mode = modes.use
@export var show_size: bool = true
@export var show_price: bool
var target: Inventory = PlayerStats.inventory
var target2: Inventory
var categories = {
	-1 : "All" ,
	Item.categories.survival : "Surival",
	Item.categories.guns : "Guns", 
	Item.categories.ammo : "Ammo",
	Item.categories.junk : "Junk"
	}
var category_index = -1
const text_style = preload("res://Art/Themes/text.tres")
@onready var item_container: MenuController = %Items
@onready var title: Label = $MarginContainer/VBoxContainer/HBoxContainer/Label
@onready var money_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Money
@onready var size_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Size
@onready var category_label: Label = %Category
@onready var stats: HBoxContainer = %Stats
@onready var stats_panel: PanelContainer = $MarginContainer/VBoxContainer/Panel
@onready var description: Label = %Label


#func _ready() -> void:
	#if "money" in target:
		#money_label.show()
		#money_label.text = "$" + str(target.money)
	#else:
		#money_label.hide()


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
	if show_size:
		var space_left = target.get_space_left()
		size_label.text = str(target.space - space_left) + "/" + str(target.space)


func set_items():
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			item_container.remove_child(child)
			child.queue_free()
	var items: Array[Control]
	for slot in target.item_slots:
		var item = slot.item
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
		inst.amount = slot.amount
		inst.owner = self
		inst.moveable = true
		if show_price:
			inst.price = item.price
			if item is EquipmentGun:
				inst.price = item.get_modified_price()
		inst.focus_entered.connect(set_description.bind(item))
		inst.delete.connect(target.items.erase.bind(inst.resource))
		inst.delete.connect(set_items)
		inst.transfer.connect(transfer_item.bind(inst))
		if mode == modes.use:
			if item is ItemUsable:
				item.target_node = target.get_local_scene()
				if item.used_up.is_connected(on_use_item):
					item.used_up.disconnect(on_use_item)
				item.used_up.connect(on_use_item.bind(inst))
				if !item.used_up.is_connected(target.items.erase):
					item.used_up.connect(target.items.erase.bind(item))
			inst.pressed.connect(item.on_pressed)
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
	filter(category_index)
	if item_container.get_child_count() > 0:
		item_container.sort_menu_items()
		item_container.set_menu_item_focus()
		item_container.get_child(0).grab_focus()


func transfer_item(menu_item: Control):
	var item = menu_item.resource
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
	if Input.is_action_pressed("shift") or item is ItemMoney:
		amount_to_move = item.amount
	if target2.add_item(item, amount_to_move):
		target.remove_item(item, amount_to_move)
	get_parent().reset_inventories()


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


func filter(category: int) -> void:
	category_label.text = categories[category]
	for child in item_container.get_children():
		var item = child.resource
		if item.category == category or category_index == -1:
			child.show()
		else:
			child.hide()
	


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		set_items()
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


func _on_left_category_pressed() -> void:
	category_index = wrapi(category_index - 1, -1, categories.size() - 1)
	filter(category_index)


func _on_right_category_pressed() -> void:
	category_index = wrapi(category_index + 1, -1, categories.size() - 1)
	filter(category_index)
