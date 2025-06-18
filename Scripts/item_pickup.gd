extends Node3D
class_name ItemPickup

@export var item: Item


func pickup():
	PlayerStats.items.append(item.duplicate())
	queue_free()
