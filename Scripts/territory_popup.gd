extends Control

@onready var capture_button: Button = $HBoxContainer/PanelContainer/MarginContainer/Button
@onready var h_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider


func _on_button_pressed() -> void:
	var current_encounter: Location = Globals.overworld.current_encounter
	#PlayerStats.owned_locations.append(current_encounter)
	current_encounter.location_data.faction = FactionManager.factions.player
	current_encounter.point_of_interest.show_faction = true
	current_encounter.point_of_interest.show_population = true
	current_encounter.flagpole.show()
	current_encounter.location_data.population = h_slider.value
	for i in h_slider.value:
		PlayerStats.allies.pop_back()
	var color = FactionManager.faction_data[current_encounter.location_data.faction].color
	current_encounter.flag.set_instance_shader_parameter("flag_color", color)
	UiController.close_interface(self)


func _on_button_2_pressed() -> void:
	UiController.close_interface(self)


func _on_visibility_changed() -> void:
	if visible:
		h_slider.max_value = PlayerStats.allies.size()
		h_slider.value = 0
		capture_button.disabled = true


func _on_h_slider_value_changed(value: float) -> void:
	capture_button.disabled = h_slider.value == 0
