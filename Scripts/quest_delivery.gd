extends Quest
class_name QuestDelivery

@export var delivery_item: ItemSlot


func start_quest() -> void:
	PlayerStats.inventory.add_item(delivery_item.item, delivery_item.amount)


func check_complete() -> void:
	if Globals.overworld.current_encounter.title == location and PlayerStats.inventory.find_item(delivery_item.item.title):
		completed = true
	else:
		completed = true


func remove_items() -> void:
	PlayerStats.inventory.remove_item(delivery_item.item, delivery_item.amount)
