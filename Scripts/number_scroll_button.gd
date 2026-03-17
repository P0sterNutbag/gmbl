extends UiButton
class_name NumberScrollButton

@export var value: float = 0
@export var max_value: float = 100
@export var min_value: float = 0
var tooltip_theme = preload("uid://dxelpr43irarh")
@onready var value_label: Label = %Label
@onready var left_button = $Control/LeftScroll
@onready var right_button = $Control/RightScroll
signal value_changed(value: float, changed_by: float)


func _ready() -> void:
	super._ready()
	value_label.text = str(int(value))


func _on_left_category_pressed() -> void:
	UiController.tab_sfx.play()
	set_value(clamp(value - 1, 0, max_value))
	value_changed.emit(value, -1.0)


func _on_right_category_pressed() -> void:
	UiController.tab_sfx.play()
	set_value(clamp(value + 1, 0, max_value)) 
	value_changed.emit(value, 1.0)


func set_value(new_value: float):
	value = new_value
	value_label.text = str(int(value))
	show_buttons()


func show_buttons() -> void:
	if value <= min_value:
		left_button.hide()
	else:
		left_button.show()
	if value >= max_value:
		right_button.hide()
	else:
		right_button.show()


func _make_custom_tooltip(for_text):
	var label = Label.new()
	label.text = for_text
	label.theme = tooltip_theme
	return label
