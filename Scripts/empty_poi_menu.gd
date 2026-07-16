extends PanelContainer

@onready var name_label: Label = $MarginContainer/VBoxContainer/Label
@onready var capture_menu: VBoxContainer = $"../CaptureMenu"
var location: Location


func activate(_location: Location) -> void:
	location = _location
	name_label.text = location.title


func _on_return_pressed() -> void:
	UiController.close_interface(self)
	location = null


func _on_enter_pressed() -> void:
	UiController.close_interface(self, false)
	location.transition_to_level()


func _on_capture_pressed() -> void:
	if PlayerStats.allies.size() == 0:
		Globals.survival_ui.create_notification("You need allies in order to capture territory")
	else:
		UiController.open_subinterface(capture_menu)


func _on_visibility_changed() -> void:
	if visible:
		activate(Globals.overworld.current_encounter)
