extends Resource
class_name Inventory

@export var item_slots: Array[ItemSlot]
@export var space: int = 10
@export var money: int
@export var title: String
var items: Array[Item]:
	get():
		var array: Array[Item] = []
		for slot in item_slots:
			var item = slot.item
			array.append(item)
		return array
var equipment_kit := EquipmentKit.new()


func add_item(item: Item, amount: int = 1) -> bool:
	if item is ItemMoney:
		money += amount
		return true
	var same_item = find_item_slot(item)
	if same_item and item.stackable:
		same_item.amount += amount
	elif get_space_left(item) > 0 or !item.takes_space:
		var new_slot = ItemSlot.new()#item.duplicate(true)
		new_slot.item = item.duplicate(true)
		new_slot.amount = amount
		item_slots.append(new_slot)
		if new_slot is Equipment:
			item.equipped = false
	else:
		return false
	return true


func remove_item(item: Item, amount: int = 1) -> void:
	var slot = find_item_slot(item)
	slot.amount -= amount
	if slot.amount <= 0:
		item_slots.erase(slot)


func find_item(item_name: String) -> Item:
	for item in items:
		if item != null and (item.resource_name == item_name or item.title.to_lower() == item_name.to_lower()):
			return item
	return null


func find_item_slot(_item: Item) -> ItemSlot:
	var item_name = _item.title
	for slot in item_slots:
		var item = slot.item
		if item != null and (item.resource_name == item_name or item.title.to_lower() == item_name.to_lower()):
			return slot
	return null


func get_item_amount(item: Item) -> int:
	var slot = find_item_slot(item)
	if slot:
		return slot.amount
	return 0


func get_space_left(item_to_add: Item = null) -> int:
	var used_space = 0
	for slot in item_slots:
		var item = slot.item
		if item.stackable:
			if !item_to_add or item.title != item_to_add.title:
				used_space += 1
		elif item.takes_space:
			used_space += slot.amount
	return space - used_space
	#var item_names: Array
	#for item in items:
		#var name = item.title
		#if !item_names.has(name):
			#item_names.append(name)
	#if item_to_add and item_to_add.stackable:
		#if item_names.has(item_to_add.title):
			#return 1
	#return space - item_names.size()
