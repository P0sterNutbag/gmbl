extends Condition
class_name ConditionVariable

enum comparisons {equals, greater_than, lesser_than}
@export var path: String
@export var value: String
@export var comparison: comparisons
@export var value2: Variant


func is_met() -> bool:
	var v1 = Globals.get_tree().root.get_node(path).get(value)
	if comparison == comparisons.equals:
		if v1 == value2:
			return true
	elif comparison == comparisons.greater_than:
		if v1 > value2:
			return true
	elif comparison == comparisons.lesser_than:
		if v1 < value2:
			return true
	return false
