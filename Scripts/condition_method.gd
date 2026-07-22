extends Condition
class_name ConditionMethod

@export var path: String
@export var method: String
@export var args: Array


func is_met() -> bool:
	var node = Globals.get_tree().root.get_node(path)
	return node.callv(method, args)
