extends Quest
class_name QuestFetch

@export var required_items: Array[ItemSlot]


func check_complete() -> void:
	for slot in required_items:
		var slot2 = PlayerStats.inventory.find_item_slot(slot.item.title)
		if !slot2 or slot2.amount < slot.amount:
			return
	completed = true


func remove_items() -> void:
	for slot in required_items:
		PlayerStats.inventory.remove_item(slot.item, slot.amount)
