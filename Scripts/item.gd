extends Resource
class_name Item

@export var title: String
@export var icon: Texture
@export var effects: Array[ChangeVariable]
@export var multiply: bool
@export var add: bool
@export var uses: int = 1
@export var price: int


func use(target_node):
	var target
	for effect in effects:
		if effect.values[0] == "hp":
			target = target_node.get_node("Hitbox")
		else:
			target = target_node
		if effect.add:
			target.set(effect.values[0], target.get(effect.values[0]) + effect.values[1])
		elif effect.multiply:
			target.set(effect.values[0], target.get(effect.values[0]) * effect.values[1])
		else:
			target.set(effect.values[0], effect.values[1])
	uses -= 1
