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
@export var show_enemy_model: bool = true
var transition_started: bool 
var can_transition: bool = true
var enemy_model: Node3D


#func _enter_tree() -> void:
	#if !Globals.overworld:
		#return
	#if Globals.overworld.current_encounter == self:
		#show_title = true
		#show_faction = true
		#show_difficulty = true
		#show_resources = true


func _ready() -> void:
	enemy_model = get_node_or_null("EnemyModel")
	if !show_enemy_model and enemy_model:
		enemy_model.hide()
	if start_with_enemies:
		location_data.population = max_population
	if "style_data" in get_parent():
		if shop:
			shop.dialogue.npc_style = get_parent().current_style
		elif dialogue_tree:
			dialogue_tree.npc_style = get_parent().current_style


func _process(_delta: float) -> void:
	if show_enemy_model:
		if location_data.population == 0:
			enemy_model.hide()
		else:
			enemy_model.show()


func start_encounter() -> void:
	if encounter_scene != null:
		Globals.overworld.current_encounter = self
		var player_vector: Vector3 = (global_position - Globals.player.global_position).normalized().rotated(Vector3.UP, -rotation.y)
		Globals.overworld.player_spawn_vector = player_vector
		SceneManager.start_scene_transition(encounter_scene.resource_path, true)
	elif town != null:
		Globals.ui.town.create_town(town)
		Globals.ui.hide_location_info()
	elif shop != null:
		Globals.ui.start_dialogue(shop.dialogue, shop)
		Globals.ui.hide_location_info()


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
