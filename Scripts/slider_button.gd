extends UiButton
class_name SliderButton

@onready var label: Label = $HBoxContainer/Label
@onready var h_slider: HSlider = $HBoxContainer/HSlider


func _process(_delta: float) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_left"):
			h_slider.value -= h_slider.step
		elif Input.is_action_just_pressed("ui_right"):
			h_slider.value += h_slider.step


func _on_h_slider_value_changed(value: float) -> void:
	label.text = str(int(value))
