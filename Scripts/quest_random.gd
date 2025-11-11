extends Resource
class_name QuestRandom

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
@export var descriptions: Array[String] = [
	"Wanted for robbery and cheating at cards.",
	"Ex wife wants him dead.",
	"Escaped slave.",
	"Wanted for stealing roomate's bagel."
]
@export var locations: Array[String] =[
	"Bandit Camp",
	"Bandit Town",
	"Crateyard",
	"Rock Canyon",
	"Sand Dunes",
]
@export var rewards: Array[Item] = [
	ItemMoney.new()
]
@export var targets: Array[PackedScene]


func generate_quest() -> Quest:
	var quest = Quest.new()
	quest.type = type
	quest.title = titles[randi_range(0, titles.size()-1)]
	quest.location = locations[randi_range(0, locations.size()-1)]
	quest.description = descriptions[randi_range(0, descriptions.size()-1)] + "Last seen at " + quest.location + "."
	quest.reward = rewards[randi_range(0, rewards.size()-1)]
	quest.reward.amount = 100
	quest.target = preload("res://Scenes/Enemies/enemy.tscn")
	return quest
