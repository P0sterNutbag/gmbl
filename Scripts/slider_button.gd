extends UiButton

@onready var label: Label = $HBoxContainer/Label


func _on_h_slider_value_changed(value: float) -> void:
	label.text = str(value)
