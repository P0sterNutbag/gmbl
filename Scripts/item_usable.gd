extends Item
class_name ItemUsable

@export var uses: int = 1
@export var effects: Array[ChangeVariable]
@export var method: String
@export var arguments: Array
@export var custom_path: String
@export var is_health_item: bool
@export var usable_in_menu: bool = true
var target_node: Node


func on_pressed():
	super.on_pressed()
	if usable_in_menu:
		use(target_node)


func use(_target_node):
	var target
	if is_health_item:
		target = Globals.player.get_node("Hitbox")
	elif custom_path != "":
		target = Globals.get_tree().root.get_node(custom_path)
	else:
		target = _target_node
	for effect in effects:
		for key in effect.values:
			if effect.add:
				target.set(key, target.get(key) + effect.values[key])
			elif effect.multiply:
				target.set(key, target.get(key) * effect.values[key])
			else:
				target.set(key, effect.values[key])
	if method != "":
		Callable(target, method).callv(arguments)
	uses -= 1
	if uses <= 0:
		used_up.emit()
