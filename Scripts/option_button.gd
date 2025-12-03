extends UiButton

@export var options: Dictionary[String, Resource]
var index: int
@onready var option_label: Label = %Label
signal option_changed(resource)


func _ready() -> void:
	option_label.text = options.keys()[index]


func _on_left_category_pressed() -> void:
	change_index(wrapi(index - 1, 0, options.size()))


func _on_right_category_pressed() -> void:
	change_index(wrapi(index + 1, 0, options.size())) 


func change_index(new_index: int):
	index = new_index
	var option_text = options.keys()[index]
	option_label.text = option_text
	option_changed.emit(options[option_text])
