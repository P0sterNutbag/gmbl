extends Resource
class_name Item

@export var title: String
@export var icon: Texture
@export var usable: bool = true
@export var effects: Array[ChangeVariable]
@export var method: String
@export var uses: int = 1
@export var price: int
@export var is_health_item: bool
@export var custom_path: String
signal used_up


func use(target_node):
	var target
	if is_health_item:
		target = Globals.player.get_node("Hitbox")
	elif custom_path != "":
		target = Globals.get_tree().root.get_node(custom_path)
	else:
		target = target_node
	for effect in effects:
		if effect.add:
			target.set(effect.values[0], target.get(effect.values[0]) + effect.values[1])
		elif effect.multiply:
			target.set(effect.values[0], target.get(effect.values[0]) * effect.values[1])
		else:
			target.set(effect.values[0], effect.values[1])
	if method != "":
		Callable(target, method).call()
	uses -= 1
	if uses <= 0:
		used_up.emit()
