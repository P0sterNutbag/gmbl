extends PanelContainer

@onready var option_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var line: Line2D = $Control/Line2D


func _process(_delta: float) -> void:
	line.set_point_position(3, Vector2(-size.x + 2, 0))
