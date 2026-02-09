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
}
@export var dialogue: DialogueTree
@export var quests: Array[Quest]
@export var random_quest: QuestRandom
@export var minimum_quests: int
var faction: FactionManager.factions
