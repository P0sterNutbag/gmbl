extends Equipment
class_name EquipmentStorage

@export var space: int


func equip() -> void:
	super.equip()
	takes_space = false
	PlayerStats.inventory.space += space


func unquip() -> void:
	super.unquip()
	takes_space = true
	PlayerStats.inventory.space -= space
