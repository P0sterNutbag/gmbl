extends TownOption
class_name QuestGiver

@export var dialogue: DialogueTree
@export var quests: Array[Quest]
@export var random_quests: Array[QuestRandom]
@export var min_quests: int
@export var max_quests: int
@export var faction: FactionManager.factions


func restock_quests() -> void:
	var amount_to_add = randi_range(min_quests, max_quests)
	amount_to_add -= quests.size()
	for i in amount_to_add:
		var quest = random_quests[randi() % random_quests.size()]
		if quest is QuestFetchRandom:
			#quest.shop = self
			quests.append(quest.generate_quest())
		if quest is QuestBountyRandom:
			quests.append(await quest.generate_quest())
