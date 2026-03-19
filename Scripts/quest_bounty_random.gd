extends QuestRandom
class_name QuestBountyRandom

@export var type: String = "Bounty"
@export var titles: Array[String] = [
	"Ace",
	"Bones",
	"Creep",
	"Dino",
	"Ernest",
	"Frag",
	"Iggy",
	"Jax",
	"Oscar",
	"Percy",
	"Quin",
	"Rusty",
	"Sully",
	"Tony",
	"Warren",
	"Xander",
]
@export var rewards: Array[Item] = [
	ItemMoney.new()
]
#@export var targets: Array[PackedScene]
@export var target_factions: Array[FactionManager.factions]


func generate_quest() -> Quest:
	var quest = QuestBounty.new()
	quest.type = type
	var locations = Globals.get_tree().get_nodes_in_group("location").filter(func(i): return target_factions.has(i.location_data.faction))
	var location = locations[randi_range(0, locations.size()-1)]
	quest.location = location.title
	var faction_name: String = FactionManager.faction_data[location.location_data.faction].name
	quest.title = "Kill " + faction_name.rstrip("s") #titles[randi_range(0, titles.size()-1)]
	quest.description = "Location: " + quest.location + ""
	quest.reward = ItemSlot.new()
	quest.reward.item = ItemMoney.new()#rewards[randi_range(0, rewards.size()-1)]
	if quest.reward.item is ItemMoney:
		var location_data = Globals.get_tree().get_nodes_in_group("location").filter(func(i): return i.title == quest.location)[0].location_data
		quest.reward.amount = location_data.population * 25
	quest.target = preload("res://Scenes/NPCs/npc.tscn")
	return quest
