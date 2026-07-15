extends DialogueBase
class_name DialogueConditionLine

enum speakers {npc, player}
enum comparisons {equals, greater_than, lesser_than}
@export var path: String
@export var value: String
@export var comparison: comparisons
@export var value2: Variant
@export_multiline var success_text: String
@export_multiline var fail_text: String
@export var speaker: speakers


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
