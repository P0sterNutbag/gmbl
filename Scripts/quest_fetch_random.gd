extends QuestRandom
class_name QuestFetchRandom

@export var required_items: Array[ItemSlot]
@export var reward_multiplier: float = 1.5

func generate_quest() -> Quest:
	var quest = QuestFetch.new()
	quest.type = "Fetch"
	quest.required_items.append(required_items[randi() % required_items.size()])
	quest.title = "Find " + str(quest.required_items[0].amount) + " " + quest.required_items[0].item.title
	quest.description = ""
	quest.reward = ItemSlot.new()
	quest.reward.item = ItemMoney.new()
	quest.reward.amount = quest.required_items[0].amount * quest.required_items[0].item.price * reward_multiplier
	return quest
