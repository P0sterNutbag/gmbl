extends Node3D

@export var encounter_scene: PackedScene
var overworld: Node3D
var transition_started: bool


func _ready() -> void:
	overworld = get_parent()


func start_encounter() -> void:
	Globals.change_scene(encounter_scene, false)


func _on_body_entered(body: Node3D) -> void:
	start_encounter()
