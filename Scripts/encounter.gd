extends Node3D

@export var location_data: LocationData
@export var spawn_parents: Array[Node3D]


func _init() -> void:
	if Globals.overworld:
		var current_data = Globals.overworld.current_encounter.location_data
		location_data = current_data
