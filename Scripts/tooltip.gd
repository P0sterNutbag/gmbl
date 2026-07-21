extends Control

@onready var description: Label = %Label
@onready var stats: VBoxContainer = %Stats


func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position()
