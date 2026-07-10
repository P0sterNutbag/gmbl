extends DialogueBase
class_name DialogueConditionMethod

enum comparisons {equals, greater_than, lesser_than}
@export var method: String
@export var arguments: Array
@export var success_branch: DialogueBranch
@export var failure_branch: DialogueBranch
