extends Node3D
class_name Location

@export var location_data: LocationData# = LocationData.new()
@export var target_distance := 0.0
@export var encounter_scene: PackedScene
@export var town: Town
@export var shop: Shop
@export var dialogue_tree: DialogueTree
@export var can_stealth_start: bool
var title: String
var alert_enemies: bool
var transition_started: bool 
var can_transition: bool = true
var shops_base_inventory: Dictionary
var shops_max_money: Dictionary
var save_population: int = -1
@onready var point_of_interest: PointOfInterest = $PointOfInterest
@onready var flag: MeshInstance3D = $Meshes/Flagpole/MeshInstance3D
@onready var flagpole: Node3D = $Meshes/Flagpole
signal encounter_started
signal encounter_ended

#func _enter_tree() -> void:
	#if !Globals.overworld:
		#return
	#if Globals.overworld.current_encounter == self:
		#show_title = true
		#show_faction = true
		#show_difficulty = true
		#show_resources = true

func _enter_tree() -> void:
	await get_tree().process_frame
	if location_data:
		var color = FactionManager.faction_colors[location_data.faction]
		flag.set_instance_shader_parameter("flag_color", color)


func _ready() -> void:
	DayNightCycle.day_start.connect(_on_day_start)
	flagpole.global_rotation_degrees = Vector3(0, 0, 0)
	if save_population > -1:
		location_data.population = save_population
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
			i.faction = location_data.faction
		stock_shops()
		DayNightCycle.day_start.connect(stock_shops)
	if shop != null:
		shops_base_inventory[shop.title] = shop.inventory.items
		shops_max_money[shop.title] = shop.inventory.money
		shop.faction = location_data.faction
		stock_shops()


func start_encounter() -> void:
	Globals.overworld.current_encounter = self
	if can_stealth_start and encounter_scene and Globals.get_dot(self, Globals.player) > -0.25:
		transition_to_level()
		return
	encounter_started.emit()
	Globals.overworld.current_encounter = self
	if dialogue_tree != null:
		Globals.ui.start_dialogue(dialogue_tree)
		point_of_interest.location_card.hide()
	elif encounter_scene != null:
		transition_to_level() 
	elif town != null:
		Globals.ui.town.create_town(town)
		point_of_interest.location_card.hide()
	elif shop != null:
		Globals.ui.job_board.shop = shop
		Globals.ui.start_dialogue(shop.dialogue, shop)
		point_of_interest.location_card.hide()


func stock_shops() -> void:
	var shops: Array
	if shop:
		shops.append(shop)
	elif town:
		shops.append_array(town.shops)
	if shops.size() == 0:
		return
	for i in shops:
		if i.inventory:
			var inventory = i.inventory
			inventory.money = shops_max_money[i.title]
			inventory.items = shops_base_inventory[i.title].duplicate_deep()
		if i.minimum_quests > 0 and i.random_quest:
			for n in i.minimum_quests - i.quests.size():
				var quest = i.random_quest.generate_quest()
				quest.return_location = point_of_interest.title
				i.quests.append(quest)


func transition_to_level(start_alert = alert_enemies) -> void:
	alert_enemies = start_alert
	var player_vector: Vector3 = (global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -global_rotation.y)
	Globals.overworld.player_spawn_vector = player_vector
	SceneManager.start_scene_transition(encounter_scene.resource_path, true)


func save() -> Dictionary:
	return {
		"save_population" : save_population,
	}


func _on_day_start() -> void:
	location_data.population = location_data.min_population


func _on_body_entered(_body: Node3D) -> void:
	if !can_transition or PlayerStats.state != PlayerStats.states.walk:
		return
	can_transition = false
	start_encounter()


func _on_body_exited(_body: Node3D) -> void:
	if Globals.overworld.process_mode == PROCESS_MODE_INHERIT:
		can_transition = true
