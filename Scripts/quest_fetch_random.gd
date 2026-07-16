extends QuestRandom
class_name QuestFetchRandom

@export var potential_items: Array[ItemSlotRandom]
@export var reward_multiplier: float = 1.5
var shop: Shop

func generate_quest() -> Quest:
	var quest = QuestFetch.new()
	quest.resource_local_to_scene = true
	quest.type = "Fetch"
	var filtered_items
	if shop:
		var illegal_items = shop.inventory.items.map(func(i): return i.title)
		filtered_items = potential_items.filter(func(a): return !illegal_items.has(a.item.title))
	else:
		filtered_items = potential_items
	if filtered_items.size() == 0:
		return null
	var item_slot = filtered_items[randi() % filtered_items.size()]
	item_slot.amount = randi_range(item_slot.amount_min, item_slot.amount_max)
	quest.required_item = item_slot
	quest.title = "Collect " + str(quest.required_item.amount) + " " + quest.required_item.item.title
	quest.description = ""
	quest.reward = ItemSlot.new()
	quest.reward.item = ItemMoney.new()
	quest.reward.amount = quest.required_item.amount * quest.required_item.item.price * reward_multiplier
	return quest
