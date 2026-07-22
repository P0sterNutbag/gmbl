extends Control

@onready var v_box_container: VBoxContainer = $VBoxContainer


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	if global_position.y + v_box_container.size.y > get_viewport_rect().size.y:
		v_box_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_KEEP_SIZE, 24)
	else:
		v_box_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_KEEP_SIZE, 24)
