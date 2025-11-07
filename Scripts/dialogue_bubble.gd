extends PanelContainer

@onready var label: Label = $MarginContainer/Label
@onready var line: Line2D = $Control/Line2D
var text: String: 
	set(value):
		text = value
		label.text = text


func _process(_delta: float) -> void:
	var length = -size.x + 2
	line.set_point_position(3, Vector2(length, 0))
