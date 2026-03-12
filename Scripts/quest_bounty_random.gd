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
	"Gimp",
	"Hemlock",
	"Iggy",
	"Jax",
	"Kritter",
	"Larry",
	"Max",
	"Nasty",
	"Oscar",
	"Percy",
	"Quin",
	"Rusty",
	"Sully",
	"Tony",
	"Vice",
	"Warren",
	"Xander",
	"Zylan",
]
@export var rewards: Array[Item] = [
	ItemMoney.new()
]
#@export var targets: Array[PackedScene]
@export var target_factions: Array[FactionManager.factions]


func generate_quest() -> Quest:
	var quest = QuestBounty.new()
	quest.type = type
	quest.title = "Kill " + titles[randi_range(0, titles.size()-1)]
	var locations = Globals.get_tree().get_nodes_in_group("location").filter(func(i): return target_factions.has(i.location_data.faction))
	quest.location = locations[randi_range(0, locations.size()-1)].title
	quest.description = "Location: " + quest.location + ""
	quest.reward = ItemSlot.new()
	quest.reward.item = rewards[randi_range(0, rewards.size()-1)]
	if quest.reward.item is ItemMoney:
		var location_data = Globals.get_tree().get_nodes_in_group("location").filter(func(i): return i.title == quest.location)[0].location_data
		quest.reward.amount = location_data.population * 25
	quest.target = preload("res://Scenes/NPCs/npc.tscn")
	return quest
