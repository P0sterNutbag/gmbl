extends Resource
class_name Inventory

@export var items: Array[Item]
@export var space: int = 10
@export var money: int
@export var title: String


func add_item(item: Item, amount: int = 1) -> bool:
	if item is ItemMoney:
		money += item.amount
		return true
	var same_item = find_item(item.title)
	if same_item and item.stackable:
		same_item.amount += amount
	elif get_space_left(item) > 0 or !item.takes_space:
		var new_item = item.duplicate(true)
		new_item.amount = amount
		items.append(new_item)
		if new_item is Equipment:
			item.equipped = false
	else:
		return false
	return true


func remove_item(item: Item, amount: int = 1) -> void:
	item.amount -= amount
	if item.amount <= 0:
		items.erase(item)


func find_item(item_name: String) -> Resource:
	for i in items:
		if i != null and (i.resource_name == item_name or i.title.to_lower() == item_name.to_lower()):
			return i
	return null



func get_space_left(item_to_add: Item = null) -> int:
	var used_space = 0
	for item in items:
		if item.stackable:
			if !item_to_add or item.title != item_to_add.title:
				used_space += 1
		elif item.takes_space:
			used_space += item.amount
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
