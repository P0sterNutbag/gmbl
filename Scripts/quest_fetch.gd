extends Quest
class_name QuestFetch

@export var required_item: ItemSlot


func check_complete() -> void:
	var slot2 = PlayerStats.inventory.find_item_slot(required_item.item)
	if slot2 and slot2.amount >= required_item.amount:
		completed = true
	else:
		completed = false


func remove_items() -> void:
	PlayerStats.inventory.remove_item(required_item.item, required_item.amount)
