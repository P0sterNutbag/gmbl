extends Control
class_name InventoryUI

enum modes {use, loot}
@export var mode = modes.use
@export var show_size: bool = true
@export var show_price: bool
@export var opposing_ui: Control
var source_inventory: Inventory = PlayerStats.inventory
var target_inventory: Inventory
var shop: Shop
var current_menu_item: MenuItem
var categories = {
	-1 : "All" ,
	Item.categories.survival : "Survival",
	Item.categories.guns : "Guns", 
	Item.categories.ammo : "Ammo",
	Item.categories.armor: "Armor",
	Item.categories.junk : "Junk",
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


func _process(_delta: float) -> void:
	if !visible or !get_parent().visible:
		return
	
	# take all
	if Input.is_action_just_pressed("reload") and mode == modes.loot:
		for item in item_container.get_children():
			for amount in item.amount:
				source_inventory.items.erase(item.item)
				target_inventory.items.append(item.item)
				item_container.remove_child(item)
		set_items()
		target_inventory.set_items()
	
	# drop
	if Input.is_action_just_pressed("drop_item"):
		if current_menu_item:
			var item = current_menu_item.resource
			source_inventory.remove_item(item)
			var item_slot = source_inventory.find_item_slot(item)
			if item_slot:
				current_menu_item.amount = item_slot.amount
			else:
				var new_index = clamp(current_menu_item.get_index() + 1, 0, 1000)
				current_menu_item.queue_free()
				item_container.get_child(new_index).grab_focus()
	
	# set money
	if money_label.visible and "money" in source_inventory:
		money_label.text = "$" + str(source_inventory.money)
	
	# set size
	if show_size:
		var space_left = source_inventory.get_space_left()
		size_label.text = str(source_inventory.space - space_left) + "/" + str(source_inventory.space)


func set_items():
	if item_container.get_child_count() > 0:
		for child in item_container.get_children():
			item_container.remove_child(child)
			child.queue_free()
	var items: Array[Control]
	for slot in source_inventory.item_slots:
		var item = slot.item
		var inst = item_container.create_menu_item()
		items.append(inst)
		inst.text = item.title
		inst.resource = item
		inst.amount = slot.amount
		inst.owner = self
		if show_price:
			var price_modifier = 1.0
			if opposing_ui.shop != null:
				price_modifier = opposing_ui.shop.price_modifiers[categories[item.category]]
			if item is EquipmentGun:
				inst.price = item.get_modified_price()
			inst.price = round(float(item.price) * price_modifier)
		inst.focus_entered.connect(_on_item_focus_entered.bind(inst))
		inst.focus_exited.connect(_on_item_focus_exited.bind(inst))
		if item is Equipment:
			if item.equipped_changed.is_connected(_on_item_equipped_changed):
				item.equipped_changed.disconnect(_on_item_equipped_changed)
			item.equipped_changed.connect(_on_item_equipped_changed.bind(inst))
		if mode == modes.use:
			if item is ItemUsable:
				item.target_node = source_inventory.get_local_scene()
				if item.used_up.is_connected(_on_use_item):
					item.used_up.disconnect(_on_use_item)
				item.used_up.connect(_on_use_item.bind(inst))
				if !item.used_up.is_connected(source_inventory.items.erase):
					item.used_up.connect(source_inventory.items.erase.bind(item))
			inst.pressed.connect(item.on_pressed)
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
			if item is Equipment and item.equipped:
				inst.text += " (equipped)"
	filter(category_index)
	if item_container.get_child_count() > 0:
		item_container.sort_menu_items()
		item_container.set_menu_item_focus()
		item_container.get_child(0).grab_focus()


func transfer_item(menu_item: Control):
	var item = menu_item.resource
	# check money
	if show_price:
		if target_inventory.money >= menu_item.price:
			target_inventory.money -= menu_item.price
			target_inventory.money += menu_item.price
			get_parent().set_inventory_money()
		else:
			opposing_ui.money_label.modulate = Color.RED
			var tween = create_tween()
			tween.tween_property(opposing_ui.money_label, "modulate", Color.WHITE, 1)
			return
	var amount_to_move = 1
	if Input.is_action_pressed("shift") or item is ItemMoney:
		amount_to_move = item.amount
	if target_inventory.add_item(item, amount_to_move):
		source_inventory.remove_item(item, amount_to_move)
	set_items()
	target_inventory.set_items()


func set_description(item: Item = null):
	for child in stats.get_children():
		child.queue_free()
	if !item:
		stats_panel.hide()
		return
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
		if item_is_in_category(item):
			if mode == modes.use and item is Equipment and item.equipped:
				child.hide()
				continue
			child.show()
		else:
			child.hide()


func item_is_in_category(item: Item) -> bool:
	if category_index == -1 or item.category == category_index:
		return true
	return false


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		set_items()
		title.text = source_inventory.title


func _on_use_item(menu_item) -> void:
	if !menu_item:
		return
	var item = menu_item.resource
	item.amount -= 1
	if item.amount <= 0:
		if menu_item.get_index() == item_container.get_child_count() - 1:
			item_container.get_child(-2).grab_focus()
		menu_item.queue_free()


func _on_item_focus_entered(menu_item: MenuItem):
	current_menu_item = menu_item
	var item = menu_item.resource
	set_description(item)


func _on_item_focus_exited(_menu_item: MenuItem):
	current_menu_item = null
	set_description()


func _on_item_equipped_changed(menu_item: MenuItem) -> void:
	var item = menu_item.resource
	if mode == modes.use and item_is_in_category(item):
		menu_item.visible = !item.equipped


func _on_left_category_pressed() -> void:
	category_index = wrapi(category_index - 1, -1, categories.size() - 1)
	filter(category_index)


func _on_right_category_pressed() -> void:
	category_index = wrapi(category_index + 1, -1, categories.size() - 1)
	filter(category_index)


#func create_physical_item(physical_item: PackedScene = null) -> void:
	#if physical_item == null or get_tree().current_scene == Globals.overworld:
		## determine amount to move
		#var amount_to_move = 1
		#if Input.is_action_just_pressed("shift"):
			#amount_to_move = resource.amount
		## move to pouch
		#var new_item = resource.duplicate()
		#new_item.amount = amount_to_move
		#var pouches: Array = Globals.player.loot_area.get_overlapping_areas()
		#pouches.filter(func(i): return i.is_in_group("pouches"))
		#if pouches.size() > 0:
			#var previous_item = Globals.find_item(pouches[0].items, resource.title)
			#if previous_item:
				#previous_item.amount += amount_to_move
			#else:
				#pouches[0].items.append(new_item)
			#return
		## create new physical pouch
		#var p = pouch.instantiate()
		#get_tree().current_scene.add_child(p)
		#var offset = -Globals.player.basis.z
		#if get_tree().current_scene == Globals.overworld:
			#offset = -Globals.player.model.basis.z
		#p.global_position = Globals.player.global_position + offset
		#p.global_position.y = Globals.get_heightmap_position(p.global_position)
		#p.items.append(new_item)
		#return
	#var inst: RigidBody3D = physical_item.instantiate()
	#get_tree().current_scene.add_child.call_deferred(inst)
	#inst.set_deferred("global_position", Globals.player.global_position + Vector3.UP * 1.5)
	#inst.apply_impulse.call_deferred(-Globals.player.basis.z * 5)
	#inst.apply_torque_impulse.call_deferred(Vector3(randf_range(-0.1, 0.1), randf_range(-5, 5), randf_range(-0.1, 0.1)))
	#inst.item = resource
	#if inst.item is EquipmentGun:
		#inst.item.gun_stats = resource.gun_stats
