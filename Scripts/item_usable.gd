extends Item
class_name ItemUsable

@export var uses: int = 1
@export var effects: Array[ChangeVariable]
@export var method: String
@export var custom_path: String
@export var is_health_item: bool
var target_node: Node


func on_pressed():
	super.on_pressed()
	use(target_node)


func use(target_node):
	var target
	if is_health_item:
		target = Globals.player.get_node("Hitbox")
	elif custom_path != "":
		target = Globals.get_tree().root.get_node(custom_path)
	else:
		target = target_node
	for effect in effects:
		for key in effect.values:
			if effect.add:
				target.set(key, target.get(key) + effect.values[key])
			elif effect.multiply:
				target.set(key, target.get(key) * effect.values[key])
			else:
				target.set(key, effect.values[key])
	if method != "":
		Callable(target, method).call()
	uses -= 1
	if uses <= 0:
		used_up.emit()
