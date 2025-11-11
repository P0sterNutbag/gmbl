extends Node3D
class_name Location

@export var location_data: LocationData = LocationData.new()
@export var max_population := 6
@export var target_distance := 0.0
@export var start_with_enemies: bool = true
@export var can_spawn_npcs: bool = true
@export var encounter_scene: PackedScene
@export var town: Town
@export var shop: Shop
@export var dialogue_tree: DialogueTree
@export var spawn_player_random: bool = false
var title: String
var transition_started: bool 
var can_transition: bool = true
var shop_timer: Timer

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
	if start_with_enemies:
		location_data.population = max_population
	if "style_data" in parent:
		if shop:
			shop.dialogue.npc_style = parent.current_style
		elif dialogue_tree:
			dialogue_tree.npc_style = parent.current_style
	# shop timer
	if town != null:
		stock_shops()
		shop_timer = Timer.new()
		shop_timer.wait_time = town.restock_timer
		shop_timer.one_shot = true
		shop_timer.timeout.connect(stock_shops)
		shop_timer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(shop_timer)


func start_encounter() -> void:
	if encounter_scene != null:
		Globals.overworld.current_encounter = self
		var player_vector: Vector3 = (global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -rotation.y)
		Globals.overworld.player_spawn_vector = player_vector
		SceneManager.start_scene_transition(encounter_scene.resource_path, true)
	elif town != null:
		Globals.ui.town.create_town(town)
		Globals.ui.hide_location_info()
		shop_timer.start()
		get_parent().location_card.hide()
	elif shop != null:
		Globals.ui.start_dialogue(shop.dialogue, shop)
		Globals.ui.hide_location_info()


func stock_shops() -> void:
	if town == null:
		return
	for i in town.shops:
		i.money = i.max_money
		if i.minimum_quests > 0:
			for n in i.minimum_quests - i.quests.size():
				var quest = QuestRandom.new().generate_quest()
				quest.return_location = get_parent().title
				i.quests.append(quest)
		if i.all_items.size() > 0:
			i.items = i.all_items.duplicate_deep()


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
