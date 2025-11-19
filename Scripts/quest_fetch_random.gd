extends QuestRandom
class_name QuestFetchRandom

@export var required_items: Array[ItemSlot]
#var rewards: Array[Item] = [
	#ItemMoney.new()
#]

func generate_quest() -> Quest:
	var quest = QuestFetch.new()
	quest.type = "Fetch"
	quest.required_items.append(required_items[randi() % required_items.size() - 1])
	quest.title = "Find " + str(quest.required_items[0].amount) + " " + quest.required_items[0].item.title
	quest.description = ""
	#quest.reward = rewards[randi_range(0, rewards.size()-1)]
	quest.reward = ItemSlot.new()
	quest.reward.item = ItemMoney.new()
	#quest.reward.item = rewards[randi_range(0, rewards.size()-1)]
	quest.reward.amount = quest.required_items[0].amount * quest.required_items[0].item.price * 2
	return quest
