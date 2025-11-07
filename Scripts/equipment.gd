extends Item
class_name Equipment

@export var name: String
@export var equipped: bool


func on_pressed() -> void:
	equip()


func pickup(target_node: Node) -> void:
	pass


func drop(target_node: Node) -> void:
	pass


func equip() -> void:
	equipped = !equipped
