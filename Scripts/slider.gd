extends HBoxContainer

@onready var label: Label = $Label


func _on_h_slider_value_changed(value: float) -> void:
	label.text = str(int(value))
