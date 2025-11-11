extends Resource
class_name Inventory

@export var items: Array[Item]
@export var space: int = 10


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
