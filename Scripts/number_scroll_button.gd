extends Button
class_name NumberScrollButton

@export var value: float = 0
@export var max_value: float = 100
@export var min_value: float = 0
var tooltip_theme = preload("uid://dxelpr43irarh")
var has_mouse: bool
@onready var value_label: Label = %Label
@onready var left_button = $Control/LeftScroll
@onready var right_button = $Control/RightScroll
signal value_changed(value: float, changed_by: float)


func _ready() -> void:
	#super._ready()
	value_label.text = str(int(value))


func _process(_delta: float) -> void:
	if !visible:
		return
	if has_mouse:
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("next_gun"):
			_on_right_category_pressed()
		elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("last_gun"):
			_on_left_category_pressed()


func _on_left_category_pressed() -> void:
	UiController.tab_sfx.play()
	var previous_value = value
	scroll_value(-1)
	if previous_value != value:
		value_changed.emit(value, -1.0)


func _on_right_category_pressed() -> void:
	UiController.tab_sfx.play()
	var previous_value = value
	scroll_value()
	if previous_value != value:
		value_changed.emit(value, 1.0)


func set_value(new_value: float):
	value = new_value
	value_label.text = str(int(value))
	show_buttons()


func scroll_value(amount: int = 1) -> void:
	if (amount > 0 and !right_button.visible) or (amount < 0 and !left_button.visible):
		return
	set_value(clamp(value + amount, 0, max_value)) 


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


func _on_mouse_entered() -> void:
	has_mouse = true


func _on_mouse_exited() -> void:
	has_mouse = false


func _on_pressed() -> void:
	_on_right_category_pressed()
