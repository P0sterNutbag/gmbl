extends UiButton

@onready var color_rect: ColorRect = $HBoxContainer/PanelContainer/MarginContainer/ColorRect


func _on_toggled(toggled_on: bool) -> void:
	color_rect.visible = toggled_on


func _on_panel_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			button_pressed = !button_pressed
			UiController.click_sfx.play()
