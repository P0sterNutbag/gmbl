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
@export var locations: Array[String] =[
	"Roadside Stop",
	"Ghost Town",
	"Crateyard",
	"Rock Canyon",
	"Sand Dunes",
]
@export var rewards: Array[Item] = [
	ItemMoney.new()
]
@export var targets: Array[PackedScene]


func generate_quest() -> Quest:
	var quest = QuestBounty.new()
	quest.type = type
	quest.title = "Kill " + titles[randi_range(0, titles.size()-1)]
	quest.location = locations[randi_range(0, locations.size()-1)]
	quest.description = "Location: " + quest.location + ""
	#quest.reward = rewards[randi_range(0, rewards.size()-1)]
	quest.reward = ItemSlot.new()
	quest.reward.item = rewards[randi_range(0, rewards.size()-1)]
	if quest.reward.item is ItemMoney:
		var location_data = Globals.get_tree().get_nodes_in_group("location").filter(func(i): return i.title == quest.location)[0].location_data
		quest.reward.amount = location_data.min_population * 25
	quest.target = preload("res://Scenes/NPCs/enemy.tscn")
	return quest
