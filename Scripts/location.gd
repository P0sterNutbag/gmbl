extends Area3D
class_name Location

@export var title: String
@export var location_data: LocationData
@export var encounter_scene: PackedScene
@export var town: Town
@export var shop: Shop
@export var friendly_dialogue_tree: DialogueTree
@export var enemy_dialogue_tree: DialogueTree
@export var unaware_dialogue_tree: DialogueTree
@export var proximity_spawn_chance := 0.5
@export var can_spawn_npcs: bool = true
@export var can_stealth_start: bool
var alert_enemies: bool
var transition_started: bool
var can_transition: bool = true
var can_proxmity_spawn: bool = true
var saved_show_faction: bool
var saved_show_population: bool
var shops_base_inventory: Dictionary
var shops_max_money: Dictionary
var saved_shops: Array[TownOption]
const NPC = preload("uid://b0cqkj1fgouo2")
@onready var point_of_interest: PointOfInterest = $PointOfInterest
@onready var flag: MeshInstance3D = $Meshes/Flagpole/MeshInstance3D
@onready var flagpole: Node3D = $Meshes/Flagpole
@onready var animation_player: AnimationPlayer = $BattleEffects/AnimationPlayer
@onready var attack_area_shape: CollisionShape3D = $AttackArea/CollisionShape3D
@onready var proximity_spawn_timer: Timer = $ProximitySpawnTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var grow_timer: Timer = $GrowTimer
signal encounter_started
@warning_ignore("unused_signal")
signal encounter_ended


func _enter_tree() -> void:
	$AttackArea/CollisionShape3D.disabled = true
	await get_tree().process_frame
	if location_data.faction == FactionManager.factions.player and get_parent() is not CharacterBody3D:
		flagpole.show()
		point_of_interest.show_faction = true
		point_of_interest.show_population = true
	if flag.visible:
		var color = FactionManager.faction_data[location_data.faction].color
		flag.set_instance_shader_parameter("flag_color", color)


func _ready() -> void:
	SaveController.load.connect(_on_load)
	flagpole.global_rotation_degrees = Vector3(0, 0, 0)
	# randomized location data
	if location_data is LocationDataRandom:
		var starting_population = randi_range(location_data.min_starting_population, location_data.max_starting_population)
		location_data.population = starting_population
		location_data.max_population = starting_population
		var starting_faction = location_data.possible_factions[randi() % location_data.possible_factions.size()]
		location_data.faction = starting_faction
	# customize dialogue
	var faction_data: Faction = FactionManager.faction_data[location_data.faction]
	if friendly_dialogue_tree:
		friendly_dialogue_tree.npc_style = faction_data.style
		friendly_dialogue_tree.npc_name = faction_data.npc_name
	if enemy_dialogue_tree:
		enemy_dialogue_tree.npc_style = faction_data.style
		friendly_dialogue_tree.npc_name = faction_data.npc_name
	if unaware_dialogue_tree:
		unaware_dialogue_tree.npc_style = faction_data.style
		friendly_dialogue_tree.npc_name = faction_data.npc_name
	if can_spawn_npcs:
		spawn_timer.start()
	await get_tree().process_frame
	if !can_spawn_npcs:
		attack_area_shape.disabled = true
	else:
		attack_area_shape.disabled = false
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
	if location_data.population == 0:
		UiController.open_interface(Globals.ui.empty_poi_menu)
		return
	var relation_score = FactionManager.get_faction_relation(location_data.faction, FactionManager.factions.player)
	if BattleManager.get_battle(self):
		transition_to_level()
	elif get_parent() is not CharacterBody3D and location_data.faction == FactionManager.factions.player:
		Globals.player.enter_town()
		UiController.open_interface(Globals.ui.poi_menu)
		point_of_interest.canvas_layer.hide()
	elif unaware_dialogue_tree and Globals.get_dot(self, Globals.player) > -0.25 and !BattleManager.get_battle(self):
		start_dialogue(unaware_dialogue_tree)
	elif relation_score < 0 and enemy_dialogue_tree:
		start_dialogue(enemy_dialogue_tree)
	elif relation_score >= 0 and friendly_dialogue_tree:
		start_dialogue(friendly_dialogue_tree)
		point_of_interest.show_population = true
		point_of_interest.show_faction = true
	elif encounter_scene:
		transition_to_level()
	elif town != null:
		enter_town()
	elif shop != null:
		enter_shop()
	encounter_started.emit()


func start_dialogue(dialogue: DialogueTree) -> void:
	Globals.ui.start_dialogue(dialogue)
	if get_parent() is not CharacterBody3D:
		Globals.player.camera.camera_type = Globals.player.camera.camera_types.town
	elif dialogue != unaware_dialogue_tree:
		get_parent().look_at(Globals.player.global_position)
	point_of_interest.canvas_layer.hide()


func enter_town() -> void:
	Globals.player.enter_town()
	Globals.ui.town.create_town(town)
	point_of_interest.canvas_layer.hide()


func enter_shop() -> void:
	Globals.player.enter_town()
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
		if i is Shop:
			i.restock_items()
		if i.has_method("restock_quests"):
			await i.restock_quests()
			for q in i.quests:
				q.return_location = title


func transition_to_level() -> void:
	SceneManager.start_encounter_transition(encounter_scene.resource_path)


func spawn_squad() -> Node3D:
	if location_data.population == 0:
		return
	# spawn and position on map
	var inst = NPC.instantiate()
	inst.faction = location_data.faction
	Globals.overworld.add_child(inst)
	inst.location.location_data.faction = location_data.faction
	inst.location.location_data.population = randi_range(min(2, location_data.population), min(4, location_data.population))
	inst.location.location_data.firepower_chance = location_data.firepower_chance
	inst.location.location_data.armor_level_chance = location_data.armor_level_chance
	inst.global_position = global_position
	inst.global_position.y = Globals.get_heightmap_position(inst.global_position)	
	var rng = RandomNumberGenerator.new()
	var weights := []
	var target_nodes = get_tree().get_nodes_in_group("location")
	target_nodes = target_nodes.filter(func(a): return a.can_spawn_npcs and a != self)
	target_nodes.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
	for i in target_nodes.size():
		var weight = max(target_nodes.size() - i, 1)
		weights.append(weight)
	var destination = target_nodes[rng.rand_weighted(weights)]
	var pos = destination.global_position
	inst.navigation_agent.set_target_position(pos)
	inst.destination = destination
	return inst


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


func _on_grow_timer_timeout() -> void:
	var amount = randi_range(1, 2)
	location_data.change_population(amount)
	if location_data.population == FactionManager.factions.player:
		Globals.survival_ui.create_notification(title + " population increased by " + str(amount))
	#var new_time = lerp(30.0, 60.0, (5.0 - location_data.resources) / 5.0)
	#grow_timer.wait_time = new_time


func _on_attack_area_body_entered(body: Node3D) -> void:
	if !can_proxmity_spawn or !can_spawn_npcs or location_data.population == 0:
		return
	if body == Globals.player:
		var population_difference = PlayerStats.allies.size() + 1 - location_data.population
		if population_difference < 0:
			return
	var relation = FactionManager.get_faction_relation(location_data.faction, body.faction)
	if "faction" in body and relation < 0:
		can_proxmity_spawn = false
		if randf() > proximity_spawn_chance:
			return
		var inst = spawn_squad()
		inst.navigation_agent.set_target_position(body.global_position)
		inst.look_at(body.global_position)
		inst.destination = self
		proximity_spawn_timer.start()


func _on_spawn_timer_timeout() -> void:
	if location_data.population > 0:
		spawn_squad()


func _on_proximity_spawn_timer_timeout() -> void:
	can_proxmity_spawn = true


func save() -> Dictionary:
	if town:
		saved_shops = town.shops
	var dict = {
		"location_data" : location_data,
		"saved_shops" : saved_shops,
		"can_proxmity_spawn" : can_proxmity_spawn,
		"saved_show_faction" : point_of_interest.show_faction,
		"saved_show_population" : point_of_interest.show_population,
	}
	if town:
		dict["town"] = town
	return dict


func _on_load() -> void:
	if town:
		town.shops = saved_shops
	if !can_proxmity_spawn:
		proximity_spawn_timer.start()
	point_of_interest.show_faction = saved_show_faction
	point_of_interest.show_population = saved_show_population
