extends DialogueOption
class_name DialogueOptionCondition

enum comparisons {equals, greater_than, lesser_than}
@export var value: String
@export var comparison: comparisons
@export var value2: Variant
@export var failue_message: String


func is_condition_true() -> bool:
	var v1 = PlayerStats.get(value)
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
