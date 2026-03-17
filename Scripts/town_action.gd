extends TownOption
class_name TownAction

@export var node_path: String
@export var method: String
@export var args: Array
@export var leave_town: bool


func do_action() -> void:
	var node = Globals.get_tree().root.get_node(node_path)
	node.callv(method, args)
