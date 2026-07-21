extends Resource
class_name ChangeVariable

@export var values: Dictionary[String, Variant]
@export var multiply: bool
@export var add: bool


func change_value(target) -> void:
	for key in values:
		if add:
			target.set(key, target.get(key) + values[key])
		elif multiply:
			target.set(key, target.get(key) * values[key])
		else:
			target.set(key, values[key])
