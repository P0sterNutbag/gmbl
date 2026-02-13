extends Equipment
class_name EquipmentStorage

@export var space: int


func equip() -> void:
	super.equip()
	takes_space = false
	PlayerStats.inventory.space += space


func unequip() -> void:
	super.unequip()
	takes_space = true
	PlayerStats.inventory.space -= space
