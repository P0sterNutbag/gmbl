extends Resource
class_name NpcData

@export var title: String = "Ally"
@export var faction: FactionManager.factions
@export var style: NpcStyle
@export var inventory: Inventory
@export var armor_level: int
@export var firepower: int
@export var gun_item: EquipmentGun
var hp: float = 3
var max_hp: float = 3


func get_rank() -> String:
	var pwr_lvl = firepower
	if pwr_lvl == 0:
		return "D"
	elif pwr_lvl == 1:
		return "C"
	elif pwr_lvl == 2:
		return "B"
	elif pwr_lvl == 3:
		return "A"
	elif pwr_lvl >= 4:
		return "S"
	return "F"
