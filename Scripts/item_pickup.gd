extends Node3D
class_name ItemPickup

@export var item: Item


func pickup(target_node: Node3D):
	if target_node.get("items") == null:
		return
	target_node.items.append(item)
	queue_free()
