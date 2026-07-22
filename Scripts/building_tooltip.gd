extends Control


func _process(_delta: float) -> void:
	if !visible:
		return
	global_position = get_global_mouse_position()
