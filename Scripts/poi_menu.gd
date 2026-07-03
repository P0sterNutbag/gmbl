extends PanelContainer

@onready var name_label: Label = $MarginContainer/VBoxContainer/Label
@onready var population_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Label
@onready var resources_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer2/Label
@onready var equipmnt_label: Label = $MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer3/Label
@onready var poi_donations: VBoxContainer = $"../PoiDonations"
var location: Location


func activate(_location: Location) -> void:
	UiController.open_interface(self)
	location = _location
	var location_data = location.location_data
	name_label.text = location.title
	population_label.text = str(location_data.population) + "/" + str(location_data.population)
	equipmnt_label.text =  "lvl " + str(location_data.fire_power + location_data.armor_level)
	resources_label.text = str(int(location_data.resources))


func _on_return_pressed() -> void:
	UiController.close_interface(self)
	location = null


func _on_enter_pressed() -> void:
	UiController.close_interface(self, false)
	location.start_encounter()


func _on_donate_pressed() -> void:
	poi_donations.activate(location)
