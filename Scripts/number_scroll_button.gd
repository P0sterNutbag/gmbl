extends UiButton

@export var value: float = 0
@export var max_value: float = 100
@export var min_value: float = 0
var tooltip_theme = preload("uid://dxelpr43irarh")
@onready var value_label: Label = %Label
signal value_changed(value: float, changed_by: float)


func _ready() -> void:
	super._ready()
	value_label.text = str(int(value))


func _on_left_category_pressed() -> void:
	UiController.tab_sfx.play()
	change_index(clamp(value - 1, 0, max_value))


func _on_right_category_pressed() -> void:
	UiController.tab_sfx.play()
	change_index(clamp(value + 1, 0, max_value)) 


func change_index(new_value: float):
	var changed_by = new_value - value
	value = new_value
	value_label.text = str(int(value))
	value_changed.emit(value, changed_by)


func _make_custom_tooltip(for_text):
	var label = Label.new()
	label.text = for_text
	label.theme = tooltip_theme
	return label
