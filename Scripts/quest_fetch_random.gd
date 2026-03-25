extends QuestRandom
class_name QuestFetchRandom

@export var potential_items: Array[ItemSlotRandom]
@export var reward_multiplier: float = 1.5


func generate_quest() -> Quest:
	var quest = QuestFetch.new()
	quest.type = "Fetch"
	var item = potential_items[randi() % potential_items.size()]
	item.amount = randi_range(item.amount_min, item.amount_max)
	quest.required_item = item
	quest.title = "Collect " + str(quest.required_item.amount) + " " + quest.required_item.item.title
	quest.description = ""
	quest.reward = ItemSlot.new()
	quest.reward.item = ItemMoney.new()
	quest.reward.amount = quest.required_item.amount * quest.required_item.item.price * reward_multiplier
	return quest
