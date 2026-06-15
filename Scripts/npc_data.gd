extends Resource
class_name NpcData

@export var title: String = "Ally"
@export var faction: FactionManager.factions
@export var style: NpcStyle
@export var inventory: Inventory
@export var armor_level: int
@export var fire_power: int
@export var gun_item: EquipmentGun


func get_rank() -> String:
	return "F"
