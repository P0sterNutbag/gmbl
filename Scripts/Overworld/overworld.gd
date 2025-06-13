extends Node3D

var current_encounter: Node3D
var kill_encounter: bool


func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	if current_encounter and kill_encounter:
		kill_encounter = false
		current_encounter.get_parent().die()


func _ready() -> void:
	Globals.overworld = self
