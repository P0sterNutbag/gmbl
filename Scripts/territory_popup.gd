extends Control


func _on_button_pressed() -> void:
	var current_encounter: Location = Globals.overworld.current_encounter
	PlayerStats.owned_locations.append(current_encounter)
	current_encounter.location_data.faction = FactionManager.factions.player
	current_encounter.point_of_interest.show_faction = true
	current_encounter.point_of_interest.show_population = true
	UiController.close_interface(self)


func _on_button_2_pressed() -> void:
	UiController.close_interface(self)
