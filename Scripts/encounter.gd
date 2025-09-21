extends Node3D

var location_data: LocationData


func _init() -> void:
	location_data = Globals.overworld.current_encounter.location_data
