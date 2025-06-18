extends Node3D

@export var encounter_scene: PackedScene
@export var town: Town
@export var title: String
@export var show_title: bool
@export var faction: String
@export var show_faction: bool
@export var difficulty: String
@export var show_difficulty: bool
@export var resources: String
@export var show_resources: bool
var transition_started: bool 
var can_transition: bool = true


func _enter_tree() -> void:
	if !Globals.overworld:
		return
	if Globals.overworld.current_encounter == self:
		show_title = true
		show_faction = true
		show_difficulty = true
		show_resources = true


func start_encounter() -> void:
	if encounter_scene != null:
		Globals.overworld.current_encounter = self
		SceneManager.start_scene_transition(encounter_scene.resource_path, true)
	else:
		Globals.ui.town.create_town(town)
		Globals.ui.hide_location_info()


func _on_body_entered(body: Node3D) -> void:
	if !can_transition:
		return
	can_transition = false
	start_encounter()


func _on_body_exited(body: Node3D) -> void:
	if Globals.overworld.process_mode == PROCESS_MODE_INHERIT:
		can_transition = true
