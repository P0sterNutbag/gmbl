extends Resource
class_name Shop

@export var title: String
@export var inventory: Inventory
@export var price_modifiers: Dictionary = {
	"Survival" : 0.75,
	"Weapons" : 0.75,
	"Armor" : 0.75,
	"Ammo" : 0.75,
	"Junk" : 0.75,
	"Gear" : 0.75,
}
@export var dialogue: DialogueTree
@export var quests: Array[Quest]
@export var random_quest: QuestRandom
@export var min_quests: int
@export var max_quests: int
var faction: FactionManager.factions


func restock_quests() -> void:
	var amount_to_add = randi_range(min_quests, max_quests)
	amount_to_add -= quests.size()
	for i in amount_to_add:
		quests.append(random_quest.generate_quest())
