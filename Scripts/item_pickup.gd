extends Node3D
class_name ItemPickup

@export var item: Item
@export var object_to_delete: Node3D = self


func pickup():
	PlayerStats.items.append(item.duplicate())
	object_to_delete.queue_free()
