extends Node3D
class_name Location

@export var location_data: LocationData = LocationData.new()
@export var target_distance := 0.0
@export var encounter_scene: PackedScene
@export var town: Town
@export var shop: Shop
@export var dialogue_tree: DialogueTree
var title: String
var transition_started: bool 
var can_transition: bool = true
var shops_base_inventory: Dictionary
var shops_max_money: Dictionary
@onready var point_of_interest: PointOfInterest = $PointOfInterest


#func _enter_tree() -> void:
	#if !Globals.overworld:
		#return
	#if Globals.overworld.current_encounter == self:
		#show_title = true
		#show_faction = true
		#show_difficulty = true
		#show_resources = true


func _ready() -> void:
	var parent = get_parent()
	if parent is PointOfInterest:
		title = parent.title
	if "style_data" in parent:
		if shop:
			shop.dialogue.npc_style = parent.current_style
		elif dialogue_tree:
			dialogue_tree.npc_style = parent.current_style
	# shop timer
	if town != null:
		for i in town.shops:
			shops_base_inventory[i.title] = i.inventory.items
			shops_max_money[i.title] = i.inventory.money
		stock_shops()
		DayNightCycle.day_start.connect(stock_shops)


func start_encounter() -> void:
	Globals.overworld.current_encounter = self
	if encounter_scene != null:
		var player_vector: Vector3 = (global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -rotation.y)
		Globals.overworld.player_spawn_vector = player_vector
		SceneManager.start_scene_transition(encounter_scene.resource_path, true)
	elif town != null:
		Globals.ui.town.create_town(town)
		#Globals.ui.hide_location_info()
		point_of_interest.location_card.hide()
	elif shop != null:
		Globals.ui.start_dialogue(shop.dialogue, shop)
		Globals.ui.hide_location_info()


func stock_shops() -> void:
	if town == null:
		return
	for i in town.shops:
		var inventory = i.inventory
		inventory.money = shops_max_money[i.title]
		if i.minimum_quests > 0:
			for n in i.minimum_quests - i.quests.size():
				var quest = QuestRandom.new().generate_quest()
				quest.return_location = point_of_interest.title
				i.quests.append(quest)
		inventory.items = shops_base_inventory[i.title].duplicate_deep()


func save() -> Dictionary:
	return {
		"location_data.population" : location_data.population,
	}


func _on_body_entered(_body: Node3D) -> void:
	if !can_transition or PlayerStats.state != PlayerStats.states.walk:
		return
	can_transition = false
	start_encounter()


func _on_body_exited(_body: Node3D) -> void:
	if Globals.overworld.process_mode == PROCESS_MODE_INHERIT:
		can_transition = true
