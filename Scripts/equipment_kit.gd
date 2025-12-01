extends Resource
class_name EquipmentKit

enum slots {primary_gun, secondary_gun, head_armor, body_armor}
var equipment := {
	slots.primary_gun: null,
	slots.secondary_gun: null,
	slots.head_armor: null,
	slots.body_armor: null,
}


func set_equippment(inventory: Inventory) -> void:
	for item in inventory:
		if item is Equipment and item.equipped:
			equipment[item.slot] = item


func get_damage_mitigation() -> float:
	var dm = 0.0
	for i in equipment:
		if i is EquipmentArmor:
			dm += i.damage_mitigation
	return dm
