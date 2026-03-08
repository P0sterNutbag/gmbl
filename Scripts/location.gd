extends Area3D
class_name Location

@export var title: String
@export var location_data: LocationData# = LocationData.new()
@export var target_distance := 0.0
@export var encounter_scene: PackedScene
@export var town: Town
@export var shop: Shop
@export var dialogue_tree: DialogueTree
@export var can_stealth_start: bool
var alert_enemies: bool
var transition_started: bool 
var can_transition: bool = true
var shops_base_inventory: Dictionary
var shops_max_money: Dictionary
var save_population: int = -1
var save_faction: FactionManager.factions
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
	SaveController.load.connect(_on_load)
	flagpole.global_rotation_degrees = Vector3(0, 0, 0)
	#if save_population > -1 and location_data:
	#	location_data.population = save_population
	#var parent = get_parent()
	#if parent is PointOfInterest:
		#title = parent.title
	#if "style_data" in parent:
		#if shop:
			#shop.dialogue.npc_style = parent.current_style
		#elif dialogue_tree:
			#dialogue_tree.npc_style = parent.current_style
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
		point_of_interest.canvas_layer.hide()
	elif encounter_scene != null:
		transition_to_level() 
	elif town != null:
		Globals.ui.town.create_town(town)
		point_of_interest.canvas_layer.hide()
	elif shop != null:
		Globals.ui.job_board.shop = shop
		Globals.ui.start_dialogue(shop.dialogue, shop)
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
		if i.inventory:
			if i.inventory is InventoryRandom:
				i.inventory.restock_inventory()
			else:
				var inventory = i.inventory
				inventory.money = shops_max_money[i.title]
				inventory.items = shops_base_inventory[i.title].duplicate_deep()
		if i.min_quests > 0 and i.random_quests.size() > 0:
			i.restock_quests()
			for q in i.quests:
				q.return_location = title


func transition_to_level(start_alert = alert_enemies) -> void:
	alert_enemies = start_alert
	var player_vector: Vector3 = (global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -global_rotation.y)
	Globals.overworld.player_spawn_vector = player_vector
	SceneManager.start_scene_transition(encounter_scene.resource_path, true)


#func start_battle(attacking_location: LocationData):
	#BattleManager.start_battle(self, attacking_location)
	#if location_data.population == 0:
		#location_data.faction = attacking_location.faction
		#location_data.population = 1#location_data.min_population
		#Globals.survival_ui.create_notification(title + " taken by " + FactionManager.faction_data[location_data.faction].name)
		#print(title + " taken by " + FactionManager.faction_data[location_data.faction].name)
		#return
	#location_data.attacking_locations.append(attacking_location)
	#if battle_timer.time_left > 0:
		#return
	#var total_population = location_data.population
	#for location in location_data.attacking_locations:
		#total_population += location.population
	#battle_timer.wait_time = total_population * 2
	#battle_timer.start()
	#animation_player.play("battle")
	#point_of_interest.status_holder.show()
	#point_of_interest.status_label.text = "Under Attack by " + FactionManager.faction_data[attacking_location.faction].name
	#if get_parent() is CharacterBody3D:
		#Globals.survival_ui.create_notification(title + " under attack by " + FactionManager.faction_data[attacking_location.faction].name)
	#print(title + " under attack by " + FactionManager.faction_data[attacking_location.faction].name)


func save() -> Dictionary:
	save_population = location_data.population
	save_faction = location_data.faction
	return {
		"save_population" : save_population,
		"save_faction" : save_faction,
	}


func _on_load() -> void:
	if save_population > -1:
		location_data.population = save_population
	location_data.faction = save_faction


func _on_body_entered(_body: Node3D) -> void:
	if !can_transition or PlayerStats.state != PlayerStats.states.walk or !Globals.player.can_enter_location:
		return
	can_transition = false
	Globals.player.can_enter_location = false
	start_encounter()


func _on_body_exited(_body: Node3D) -> void:
	if Globals.overworld.process_mode == PROCESS_MODE_INHERIT:
		can_transition = true
		Globals.player.can_enter_location = true


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
