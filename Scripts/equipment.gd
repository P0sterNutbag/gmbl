extends Item
class_name Equipment

@export var equipped: bool
@export var slot: EquipmentKit.slots
signal equipped_changed


func on_pressed() -> void:
	equip()


func pickup(target_node: Node) -> void:
	pass


func drop(target_node: Node) -> void:
	pass


func equip() -> void:
	var kit = PlayerStats.inventory.equipment_kit
	equipped = !equipped
	if equipped:
		var previous_equip = kit.equipment[slot]
		if previous_equip:
			previous_equip.equipped = false
			previous_equip.equipped_changed.emit()
		kit.equipment[slot] = self
	else:
		kit.equipment[slot] = null
	PlayerStats.inventory.equipment_kit = kit
	equipped_changed.emit()
