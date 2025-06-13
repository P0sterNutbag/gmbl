extends Node3D

@export var encounter_scene: PackedScene
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


func start_encounter() -> void:
	Globals.overworld.current_encounter = self
	SceneManager.start_scene_transition(encounter_scene.resource_path, true)


func _on_body_entered(body: Node3D) -> void:
	if !can_transition:
		return
	can_transition = false
	start_encounter()


func _on_body_exited(body: Node3D) -> void:
	if Globals.overworld.process_mode == PROCESS_MODE_INHERIT:
		can_transition = true
