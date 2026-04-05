extends Resource
class_name Inventory

@export var item_slots: Array[ItemSlot]
@export var space: int = 10:
	get():
		return space + space_modifier
@export var money: int
@export var title: String
var space_modifier: int = 0 
var items: Array[Item]:
	get():
		var array: Array[Item] = []
		for slot in item_slots:
			var item = slot.item
			array.append(item)
		return array
var equipment_kit := EquipmentKit.new() 


func add_item(item: Item, amount: int = 1, create_notification: bool = false) -> bool:
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
		if create_notification:
			Globals.survival_ui.create_notification("Not enough room in inventory")
		return false
	if create_notification:
		Globals.survival_ui.create_notification(item.title + " added to inventory")
	return true


func remove_item(item: Item, amount: int = 1, create_notification: bool = false) -> void:
	var slot = find_item_slot(item)
	if !slot:
		return
	slot.amount -= amount
	if slot.amount <= 0:
		item_slots.erase(slot)
	if create_notification:
		Globals.survival_ui.create_notification(item.title + " removed from inventory")


func remove_item_by_name(item_name: String, amount: int = 1, create_notification: bool = false) -> void:
	var item = find_item(item_name)
	remove_item(item, amount, create_notification)


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
			if item is Equipment and item.equipped:
				continue
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
		if !item.takes_space:
			continue
		if item.stackable:
			if !item_to_add or item.title != item_to_add.title:
				used_space += 1
		elif item.takes_space:
			used_space += slot.amount
	return space - used_space


func equip_item(item_to_equip: Equipment) -> void:
	equipment_kit.equipment[item_to_equip.slot] = item_to_equip
	
