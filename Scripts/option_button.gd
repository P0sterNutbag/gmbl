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
	change_index(wrapi(index - 1, 0, options.size()))


func _on_right_category_pressed() -> void:
	change_index(wrapi(index + 1, 0, options.size())) 


func change_index(new_index: int):
	index = new_index
	var option_text = options[index].string
	option_label.text = option_text
	option_changed.emit(options[index].value)
