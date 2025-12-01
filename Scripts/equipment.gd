extends Item
class_name Equipment

@export var name: String
@export var equipped: bool
@export var slot: EquipmentKit.slots
@export var array_name: String
signal equipped_changed


func on_pressed() -> void:
	equip()


func pickup(target_node: Node) -> void:
	pass


func drop(target_node: Node) -> void:
	pass


func equip() -> void:
	equipped = !equipped
	var array = PlayerStats.get(array_name)
	for item in array:
		if item and item != self and item.slot == slot:
			item.equipped = false
			item.equipped_changed.emit()
	if equipped:
		array[slot] = self
	else:
		array[slot] = null
	equipped_changed.emit()
