extends Area3D
class_name Location

@export var title: String
@export var location_data: LocationData# = LocationData.new()
@export var encounter_scene: PackedScene
@export var town: Town
@export var shop: Shop
@export var dialogue_tree: DialogueTree
@export var can_spawn_npcs: bool = true
@export var can_stealth_start: bool
var alert_enemies: bool
var transition_started: bool 
var can_transition: bool = true
var shops_base_inventory: Dictionary
var shops_max_money: Dictionary
var save_population: int = -1
var save_faction: FactionManager.factions
var unaware_dialogue = preload("uid://dhbjweb7dwnpn")
@onready var point_of_interest: PointOfInterest = $PointOfInterest
@onready var flag: MeshInstance3D = $Meshes/Flagpole/MeshInstance3D
@onready var flagpole: Node3D = $Meshes/Flagpole
@onready var battle_timer: Timer = $BattleTimer
@onready var animation_player: AnimationPlayer = $BattleEffects/AnimationPlayer
signal encounter_started
@warning_ignore("unused_signal")
signal encounter_ended


func _enter_tree() -> void:
	await get_tree().process_frame
	#if location_data:
		#var color = FactionManager.faction_data[location_data.faction].color
		#flag.set_instance_shader_parameter("flag_color", color)


func _ready() -> void:
	#SaveController.load.connect(_on_load)
	flagpole.global_rotation_degrees = Vector3(0, 0, 0)
	# randomized location data
	if location_data is LocationDataRandom:
		var starting_population = randi_range(location_data.min_starting_population, location_data.max_starting_population)
		location_data.population = starting_population
		location_data.max_population = starting_population
		var starting_faction = location_data.possible_factions[randi() % location_data.possible_factions.size()]
		location_data.faction = starting_faction
	await get_tree().process_frame
	# shop timer
	if town != null:
		for i in town.shops:
			if i is Shop:
				if i.inventory:
					i.max_money = i.inventory.money
				i.faction = location_data.faction
		DayNightCycle.day_start.connect(stock_shops)
	if shop:
		shop.faction = location_data.faction
		shop.max_money = shop.inventory.money
	if !SaveController.has_loaded and (town != null or shop != null):
		stock_shops()


func start_encounter() -> void:
	Globals.overworld.current_encounter = self
	encounter_started.emit()
	if can_stealth_start and encounter_scene and Globals.get_dot(self, Globals.player) > -0.25:
		if dialogue_tree:
			Globals.ui.start_dialogue(unaware_dialogue)
			Globals.player.camera_type = Globals.player.camera_types.town
			point_of_interest.canvas_layer.hide()
		else:
			transition_to_level()
		return
	if dialogue_tree != null and !BattleManager.get_battle(self) and location_data.population > 0:
		Globals.ui.start_dialogue(dialogue_tree)
		Globals.player.camera_type = Globals.player.camera_types.town
		point_of_interest.canvas_layer.hide()
	elif encounter_scene != null:
		transition_to_level() 
	elif town != null:
		Globals.ui.town.create_town(town)
		Globals.player.camera_type = Globals.player.camera_types.town
		point_of_interest.canvas_layer.hide()
	elif shop != null:
		Globals.ui.job_board.shop = shop
		Globals.ui.start_dialogue(shop.dialogue, shop)
		Globals.player.camera_type = Globals.player.camera_types.town
		point_of_interest.canvas_layer.hide()


func stock_shops() -> void:
	var shops: Array
	if shop:
		shops.append(shop)
	elif town:
		shops.append_array(town.shops)
	if shops.size() == 0:
		return
	for i in shops:
		if i is Shop:
			i.restock_items()
		if i.has_method("restock_quests"):
			await i.restock_quests()
			for q in i.quests:
				q.return_location = title


func transition_to_level(start_alert = alert_enemies) -> void:
	alert_enemies = start_alert
	var player_vector: Vector3 = (global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -global_rotation.y)
	Globals.overworld.player_spawn_vector = player_vector
	SceneManager.start_encounter_transition(encounter_scene.resource_path)


func _on_body_entered(_body: Node3D) -> void:
	if !can_transition or PlayerStats.state != PlayerStats.states.walk or !Globals.player.can_enter_location:
		return
	can_transition = false
	Globals.player.can_enter_location = false
	Globals.player.navigation_agent.target_position = Vector3.ZERO
	start_encounter()


func _on_body_exited(_body: Node3D) -> void:
	if Globals.overworld.process_mode == PROCESS_MODE_INHERIT:
		can_transition = true
		Globals.player.can_enter_location = true
	Globals.player.camera_type = Globals.player.camera_types.overhead


func _on_battle_timer_timeout() -> void:
	var factions = []
	for i in location_data.population:
		factions.append(location_data.faction)
	for location in location_data.attacking_locations:
		for i in location.population:
			factions.append(location.faction)
	var original_faction = location_data.faction
	location_data.faction = factions[randi() % factions.size()]
	if location_data.faction == FactionManager.factions.no_faction:
		location_data.population = 0
		location_data.faction = original_faction
		location_data.attacking_locations = location_data.attacking_locations.filter(func(a): return a.faction != FactionManager.factions.no_faction)
	else:
		location_data.population = randi() % factions.filter(func(a): return a == location_data.faction).size()
		location_data.population = clampi(location_data.population, 1, location_data.max_population)
		location_data.attacking_locations.clear()
	animation_player.stop()
	point_of_interest.status_holder.hide()
	if location_data.faction != original_faction:
		Globals.survival_ui.create_notification(title + " taken by " + FactionManager.faction_data[location_data.faction].name)
		print(title + " taken by " + FactionManager.faction_data[location_data.faction].name + ". Population is now: " + str(location_data.population))
	else:
		print(title + " successfuly defended by " + FactionManager.faction_data[location_data.faction].name + ". Population is now: " + str(location_data.population))


func save() -> Dictionary:
	var dict = {
		"location_data" : location_data
	}
	if town:
		dict["town"] = town
	return dict
