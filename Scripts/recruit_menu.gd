extends VBoxContainer

@onready var h_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider
@onready var poi_menu: PanelContainer = $"../PoiMenu"


func activate(location: Location) -> void:
	var location_data = location.location_data
	h_slider.value = 0
	h_slider.max_value = location_data.population


func _on_recruit_pressed() -> void:
	var location_data = Globals.overworld.current_encounter.location_data
	for i in h_slider.value:
		location_data.population = clamp(location_data.population - 1, 0, 100)
		var npc_data = NpcData.new()
		npc_data.style = FactionManager.faction_data[Globals.overworld.current_encounter.location_data.faction].style.generate_style()
		npc_data.fire_power = location_data.fire_power
		npc_data.armor_level = location_data.armor_level
		PlayerStats.allies.append(npc_data)
	Globals.survival_ui.create_notification(str(int(h_slider.value)) + " allies added to party")
	UiController.open_interface(poi_menu)


func _on_exit_pressed() -> void:
	UiController.open_interface(poi_menu)


func _on_visibility_changed() -> void:
	if visible:
		activate(Globals.overworld.current_encounter)
