extends QuestRandom
class_name QuestDeliveryRandom

@export var potential_items: Array[ItemSlot]
@export var target_factions: Array[FactionManager.factions]


func generate_quest() -> Quest:
	var quest = QuestDelivery.new()
	quest.type = "Delivery"
	var item = potential_items[randi() % potential_items.size()]
	quest.delivery_item = item
	var locations = Globals.get_tree().get_nodes_in_group("location").filter(func(i): return (target_factions.has(i.location_data.faction) 
		and (i.town != null or i.shop != null) 
		and i != Globals.overworld.current_encounter))
	var location = locations[randi_range(0, locations.size()-1)]
	quest.location = location.title
	quest.title = "Deliver " + str(item.amount) + " " + str(quest.delivery_item.item.title) + "s to " + quest.location
	quest.description = ""
	quest.reward = ItemSlot.new()
	quest.reward.item = ItemMoney.new()
	quest.reward.amount = item.item.price * item.amount * 2
	return quest
