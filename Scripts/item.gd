extends Resource
class_name Item

@export var icon: Texture 
@export var effects: Array[ChangeVariable]
@export var multiply: bool
@export var add: bool
@export var uses: int
signal used_up

func use(target_node: Node):
	for effect in effects:
		if effect.add:
			target_node.set(effect.values[0], target_node.get(effect.values[0]) + effect.values[1])
		elif effect.multiply:
			target_node.set(effect.values[0], target_node.get(effect.values[0]) * effect.values[1])
		else:
			target_node.set(effect.values[0], effect.values[1])
	uses -= 1
