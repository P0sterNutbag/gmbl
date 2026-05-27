extends Button

@export var options: Array[StringValuePair]
@export var index: int
var has_mouse: bool
@onready var option_label: Label = %Label
signal option_changed(value)


func _ready() -> void:
	#super._ready()
	#await get_tree().current_scene.ready
	option_label.text = options[index].string


func _process(delta: float) -> void:
	if has_mouse:
		if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("next_gun"):
			_on_right_category_pressed()
		elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("last_gun"):
			_on_left_category_pressed()


func _on_left_category_pressed() -> void:
	UiController.tab_sfx.play()
	change_index(wrapi(index - 1, 0, options.size()))


func _on_right_category_pressed() -> void:
	UiController.tab_sfx.play()
	change_index(wrapi(index + 1, 0, options.size())) 


func change_index(new_index: int) -> void:
	index = new_index
	var option_text = options[index].string
	option_label.text = option_text
	option_changed.emit(options[index].value)


func scroll_index(amount: int = 1) -> void:
	index = wrapi(index + amount, 0, options.size())
	change_index(index)


func set_index_by_value(value) -> void:
	for i in options.size():
		var option = options[i]
		if option.value == value:
			change_index(i)


func get_random_option():
	index = randi() % options.size()
	var option = options[index]
	var option_text = options[index].string
	option_label.text = option_text
	return option.value


func _on_pressed() -> void:
	scroll_index()


func _on_mouse_entered() -> void:
	has_mouse = true


func _on_mouse_exited() -> void:
	has_mouse = false
