extends MenuList

@export var target_box: MenuList
var capacity: int:
	set(value):
		capacity = value
		capacity_label.text = str(population) + "/" + str(capacity)
var population: int:
	set(value):
		population = value
		capacity_label.text = str(population) + "/" + str(capacity)
var location_data: LocationData
@onready var capacity_label: Label = %Capacity
@onready var title_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Label
const ALLY = preload("uid://cikxsk48swg6f")


func set_location(data: LocationData) -> void:
	location_data = data
	title_label.text = location_data.title
	capacity = location_data.max_population
	population = location_data.npcs.size()
	item_container.delete_children()
	for npc in location_data.npcs:
		var ally_button = item_container.add_button(ALLY)
		ally_button.npc_data = npc
		ally_button.pressed.connect(switch_ally.bind(ally_button))


func switch_ally(ally_button: Control) -> void:
	if target_box.location_data.npcs.size() >= target_box.location_data.max_population:
		return
	location_data.npcs.erase(ally_button.npc_data)
	target_box.location_data.npcs.append(ally_button.npc_data)
	set_location(location_data)
	target_box.set_location(target_box.location_data)
