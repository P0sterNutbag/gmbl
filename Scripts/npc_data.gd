extends Resource
class_name NpcData

@export var title: String = "Ally"
@export var faction: FactionManager.factions
@export var style: NpcStyle
@export var inventory: Inventory
@export var armor_level: int
@export var fire_power: int
@export var gun_item: EquipmentGun
var hp: float = 3
var max_hp: float = 3


func get_rank() -> String:
	var pwr_lvl = armor_level + fire_power
	if pwr_lvl == 0:
		return "F"
	elif pwr_lvl == 1:
		return "D"
	elif pwr_lvl == 2:
		return "C"
	elif pwr_lvl == 3:
		return "B"
	elif pwr_lvl == 4:
		return "A"
	elif pwr_lvl >= 5:
		return "S"
	return "F"
