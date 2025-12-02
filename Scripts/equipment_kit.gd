extends Resource
class_name EquipmentKit

enum slots {primary_gun, secondary_gun, head_armor, body_armor, navigation, light, vision}
var equipment := {
	slots.primary_gun: null,
	slots.secondary_gun: null,
	slots.head_armor: null,
	slots.body_armor: null,
	slots.navigation: null,
	slots.light: null,
	slots.vision: null,
}
var gun_slots := [slots.primary_gun, slots.secondary_gun]


func remove_all() -> void:
	for i in equipment:
		equipment[i] = null


func get_damage_modifier() -> float:
	var dm = 1.0
	for i in equipment:
		var item = equipment[i]
		if item is EquipmentArmor:
			dm -= item.damage_modifier
	return dm
