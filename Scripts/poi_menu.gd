extends PanelContainer

@onready var name_label: Label = $MarginContainer/VBoxContainer/Label
@onready var population_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Label
@onready var resources_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label
@onready var equipmnt_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer3/Label
@onready var poi_donations: VBoxContainer = $"../PoiDonations"
@onready var recruit_menu: VBoxContainer = $"../RecruitMenu"
var location: Location


func activate(_location: Location) -> void:
	location = _location
	var location_data = location.location_data
	name_label.text = location.title
	population_label.text = str(location_data.population) + "/" + str(location_data.max_population)
	equipmnt_label.text =  "lvl " + str(location_data.fire_power + location_data.armor_level)
	resources_label.text = str(int(location_data.resources))


func _on_return_pressed() -> void:
	UiController.close_interface(self)
	location = null


func _on_enter_pressed() -> void:
	UiController.close_interface(self, false)
	location.transition_to_level()


func _on_donate_pressed() -> void:
	UiController.open_subinterface(poi_donations)


func _on_recruit_pressed() -> void:
	if location.location_data.population <= 0:
		Globals.survival_ui.create_notification("There's no one here to recruit.")
	else:
		UiController.open_subinterface(recruit_menu)


func _on_visibility_changed() -> void:
	if visible:
		activate(Globals.overworld.current_encounter)
