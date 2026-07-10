extends DialogueBase
class_name DialogueConditionVariable

enum comparisons {equals, greater_than, lesser_than}
@export var path: String
@export var value: String
@export var comparison: comparisons
@export var value2: Variant
@export var success_branch: DialogueBranch
@export var failure_branch: DialogueBranch


func is_condition_true() -> bool:
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
