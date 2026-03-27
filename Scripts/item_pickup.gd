extends InteractableObject
class_name ItemPickup

@export var item_slot: ItemSlot
@export var object_to_delete: Node3D = self


func interact() -> void:
	super.interact()
	if index == 0:
		if PlayerStats.inventory.add_item(item_slot.item, item_slot.amount):
			object_to_delete.queue_free()
