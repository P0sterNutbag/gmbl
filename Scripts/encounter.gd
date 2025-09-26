extends Node3D

@export var location_data: LocationData


func _init() -> void:
	if Globals.overworld:
		location_data = Globals.overworld.current_encounter.location_data
