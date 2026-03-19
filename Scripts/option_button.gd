extends UiButton

@export var options: Array[StringValuePair]
var index: int
@onready var option_label: Label = %Label
signal option_changed(value)


func _ready() -> void:
	super._ready()
	#await get_tree().current_scene.ready
	option_label.text = options[index].string


func _on_left_category_pressed() -> void:
	UiController.tab_sfx.play()
	change_index(wrapi(index - 1, 0, options.size()))


func _on_right_category_pressed() -> void:
	UiController.tab_sfx.play()
	change_index(wrapi(index + 1, 0, options.size())) 


func change_index(new_index: int):
	index = new_index
	var option_text = options[index].string
	option_label.text = option_text
	option_changed.emit(options[index].value)


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
