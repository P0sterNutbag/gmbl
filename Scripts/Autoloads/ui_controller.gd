extends Node

var ui_nodes: Array[Control]


func open_interface(node_to_open: Control, pause_player: bool = true) -> void:
	if !ui_nodes.has(node_to_open):
		ui_nodes.append(node_to_open)
	for node in ui_nodes:
		if node == node_to_open:
			node.show()
		else:
			node.hide()
	if pause_player:
		PlayerStats.change_state(PlayerStats.states.pause)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_interface(node_to_close: Control, activate_player: bool = true) -> void:
	node_to_close.hide()
	if activate_player:
		PlayerStats.change_state(PlayerStats.states.walk)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func close_all(activate_player: bool = true) -> void:
	for node in ui_nodes:
		node.hide()
	if activate_player:
		PlayerStats.change_state(PlayerStats.states.walk)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func is_canvas_layer_open(canvas_layer: CanvasLayer) -> bool:
	for node in ui_nodes:
		if node.visible and node.get_parent() == canvas_layer:
			return true
	return false


func reset_list():
	ui_nodes.clear()
