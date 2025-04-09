extends Node3D
class_name GunPickup

@export var gun_name: String
@export var ammo: Resource

func pickup(target_node: Node3D):
	if target_node.get("guns") == null:
		return
	var new_gun = target_node.get(gun_name)
	if !target_node.guns.has(new_gun):
		target_node.guns.append(new_gun)
	else:
		target_node.items.append(ammo)
	queue_free()
