extends Resource
class_name Shop

@export var title: String
#@export var all_items: Array[Item]
#var items: Array[Item] = all_items.duplicate_deep()
#@export var money: int = 100
@export var inventory: Inventory
@export var dialogue: DialogueTree
@export var quests: Array[Quest]
@export var minimum_quests: int
