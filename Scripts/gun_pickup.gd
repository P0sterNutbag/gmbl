extends ItemPickup
class_name GunPickup

@export var ammo_item: ItemUsable
@export var item_amount: int = 1


func _ready() -> void:
	actions = ["Pick up", "Take Ammo"]


func interact() -> void:
	super.interact()
	if index == 0:
		if PlayerStats.inventory.add_item(item_slot.item, item_slot.amount):
			object_to_delete.queue_free()
	elif index == 1:
		if randf() < 0.25:
			if PlayerStats.inventory.add_item(ammo_item, item_amount, true):
				item_slot.item.gun_stats.ammo = 0
			actions.remove_at(1)
			index = 0
		else:
			Globals.survival_ui.create_notification("No ammo found")
			actions.remove_at(1)
			index = 0
