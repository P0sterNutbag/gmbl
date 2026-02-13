extends Control
class_name InventoryUI

enum modes {use, loot}
@export var mode = modes.use
@export var show_size: bool = true
@export var show_price: bool
@export var show_money: bool = true
@export var show_space: bool = true
@export var can_drop_items: bool
@export var opposing_ui: Control
var faction_discount := 0.2
var is_ready: bool
var source_inventory: Inventory = PlayerStats.inventory
var target_inventory: Inventory
var shop: Shop
var current_menu_item: MenuItem
var menu_item_to_drop: MenuItem
var categories = {
	-1 : "All" ,
	Item.categories.guns : "Weapons",
	Item.categories.ammo : "Ammo",
	Item.categories.consumable : "Consumable",
	Item.categories.gear : "Gear",
	Item.categories.armor: "Armor",
	Item.categories.junk : "Junk",
	}
var category_icons := {
	Item.categories.consumable : preload("uid://d255ivp8epdww"),
	Item.categories.guns : preload("uid://bawi5rh4k705r"),
	Item.categories.ammo : preload("uid://cfaqpxn6m5qtm"),
	Item.categories.armor: preload("uid://blmj1u6o3d12r"),
	Item.categories.junk : preload("uid://dchj1pn34qgj6"),
	Item.categories.gear : preload("uid://bhmodnqjb2gkx"),
}
var category_index = -1
const text_style = preload("res://Art/Themes/text_small.tres")
@onready var item_container: MenuController = %Items
@onready var title: Label = $MarginContainer/VBoxContainer/Label
@onready var money_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Money
@onready var size_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/Size
@onready var category_label: Label = %Category
@onready var stats: HBoxContainer = %Stats
@onready var stats_panel: PanelContainer = $MarginContainer/VBoxContainer/Panel
@onready var description: Label = %Label
@onready var use_controls: HBoxContainer = $Controls/HBoxContainer
@onready var loot_controls: HBoxContainer = $Controls/HBoxContainer2
@onready var drop_menu: Control = $DropMenu
@onready var drop_item_text: Label = $DropMenu/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var drop_amount_h_slider: HSlider = $DropMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider
@onready var drop_amount_label: Label = $DropMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Label


func _ready() -> void:
	is_ready = true
	money_label.visible = show_money
	size_label.visible = show_space


func _process(_delta: float) -> void:
	if !visible or !get_parent().visible:
		return
	# drop
	if Input.is_action_just_pressed("drop_item") and can_drop_items:
		if current_menu_item:
			menu_item_to_drop = current_menu_item
			drop_menu.show()
	# set money
	if money_label.visible:
		money_label.text = "$" + str(source_inventory.money)
	# set size
	if show_size:
		var space_left = source_inventory.get_space_left()
		size_label.text = str(source_inventory.space - space_left) + "/" + str(source_inventory.space)


func set_items():
	title.text = source_inventory.title
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
		inst.icon_texture_unfocus = category_icons[item.category]
		inst.icon = inst.icon_texture_unfocus
		if show_price:
			var price_modifier = 1.0
			if shop:
				var faction_rating = FactionManager.get_faction_relation(shop.faction, FactionManager.factions.player)
				price_modifier -= sign(faction_rating) * faction_discount
			if opposing_ui.shop != null:
				price_modifier = opposing_ui.shop.price_modifiers[categories[item.category]]
			if item is EquipmentGun:
				inst.price = round(item.get_modified_price() * price_modifier)
			else:
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
				if !item.used_up.is_connected(source_inventory.remove_item):
					item.used_up.connect(source_inventory.remove_item.bind(item))
			inst.pressed.connect(item.on_pressed)
		elif mode == modes.loot:
			inst.pressed.connect(transfer_item.bind(inst))
			if item is Equipment and item.equipped and source_inventory == PlayerStats.inventory:
				inst.text += " (equipped)"
	filter(category_index)
	if item_container.get_child_count() > 0:
		#item_container.sort_menu_items()
		sort_by_category()


func transfer_item(menu_item: Control):
	var item = menu_item.resource
	# check money
	if show_price and target_inventory.money < menu_item.price:
		opposing_ui.money_label.modulate = Color.RED
		var tween = create_tween()
		tween.tween_property(opposing_ui.money_label, "modulate", Color.WHITE, 1)
		UiController.stop_audio()
		UiController.error_sfx.play()
		return
	var amount_to_move = 1
	if Input.is_action_pressed("shift") or item is ItemMoney:
		amount_to_move = menu_item.resource.amount		
	if item is EquipmentGun and item.equipped:
		item.equip()
	if target_inventory.add_item(item, amount_to_move):
		source_inventory.remove_item(item, amount_to_move)
		set_items()
		opposing_ui.set_items()
		if show_price:
			source_inventory.money += menu_item.price
			target_inventory.money -= menu_item.price
	else:
		UiController.stop_audio()
		UiController.error_sfx.play()


func set_description(item: Item = null):
	for child in stats.get_children():
		child.queue_free()
	if !item:
		stats_panel.hide()
		return
	if item.description != "":
		description.show()
		description.text = item.description
		stats_panel.show()
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
				source_inventory.equip_item(child.resource)
				child.hide()
				continue
			child.show()
		else:
			child.hide()


func sort_by_category() -> void:
	var sorted_children = []
	for category in categories:
		var filtered_children = item_container.get_children()
		filtered_children = filtered_children.filter(func(a): return a.resource.category == category) 
		filtered_children.sort_custom(func(a, b): return a.text.naturalnocasecmp_to(b.text) < 0)
		sorted_children.append_array(filtered_children)
	for child in item_container.get_children():
		item_container.move_child.call_deferred(child, sorted_children.find(child))
		#child.focus_neighbor_top = NodePath("")
		#child.focus_neighbor_bottom = NodePath("")
	item_container.set_menu_item_focus()



func item_is_in_category(item: Item) -> bool:
	if category_index == -1 or item.category == category_index:
		return true
	return false


func drop_item():
	var item = menu_item_to_drop.resource
	source_inventory.remove_item(item, int(drop_amount_h_slider.value))
	var item_slot = source_inventory.find_item_slot(item)
	if item_slot:
		menu_item_to_drop.amount = item_slot.amount
	else:
		menu_item_to_drop.queue_free()


func _on_v_box_container_visibility_changed() -> void:
	if visible and get_parent().visible:
		if !is_ready:
			await ready
		set_items()
		title.text = source_inventory.title
	else:
		drop_menu.hide()


func _on_use_item(menu_item) -> void:
	if !menu_item:
		return
	var item = menu_item.resource
	source_inventory.remove_item(item)
	set_items()


func _on_item_focus_entered(menu_item: MenuItem):
	current_menu_item = menu_item
	var item = menu_item.resource
	set_description(item)


func _on_item_focus_exited(_menu_item: MenuItem):
	current_menu_item = null
	set_description()


func _on_item_equipped_changed(menu_item: MenuItem) -> void:
	var item = menu_item.resource
	#source_inventory.equipment_kit.equipment[item.slot] = item
	if mode == modes.use and item_is_in_category(item):
		menu_item.visible = !item.equipped


func _on_left_category_pressed() -> void:
	category_index = wrapi(category_index - 1, -1, categories.size() - 1)
	filter(category_index)
	UiController.tab_sfx.play()


func _on_right_category_pressed() -> void:
	category_index = wrapi(category_index + 1, -1, categories.size() - 1)
	filter(category_index)
	UiController.tab_sfx.play()


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


func _on_drop_item_pressed() -> void:
	drop_item()
	drop_menu.hide()


func _on_dont_drop_pressed() -> void:
	drop_menu.hide()


func _on_drop_menu_visibility_changed() -> void:
	if drop_menu.visible:
		var item = menu_item_to_drop.resource
		drop_item_text.text = "Drop " + item.title + "?"
		drop_amount_h_slider.max_value = PlayerStats.inventory.get_item_amount(item)
		drop_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		drop_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_h_slider_value_changed(value: float) -> void:
	drop_amount_label.text = str(int(value))
