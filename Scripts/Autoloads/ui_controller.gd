extends Node

var ui_nodes: Array[Control]
var current_ui: Control
var mouse_speed := 800.0
#region SFX
@onready var click_sfx: AudioStreamPlayer = $Click
@onready var hover_sfx: AudioStreamPlayer = $Hover
@onready var tab_sfx: AudioStreamPlayer = $Tab
@onready var error_sfx: AudioStreamPlayer = $Error
@onready var voice_sfx: AudioStreamPlayer = $Voice
#endregion


func _process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN and Input.get_connected_joypads().size() > 0:
		var controller_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down", 0.25)
		var mouse_pos = get_viewport().get_mouse_position()
		get_viewport().warp_mouse(mouse_pos + controller_vector * mouse_speed * delta)


func open_interface(node_to_open: Control, pause_player: bool = true, show_mouse: bool = true) -> void:
	if !ui_nodes.has(node_to_open):
		ui_nodes.append(node_to_open)
	for node in ui_nodes:
		if node == node_to_open:
			node.show()
			current_ui = node
		else:
			node.hide()
	if pause_player:
		PlayerStats.change_state(PlayerStats.states.pause)
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif show_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func close_interface(node_to_close: Control, activate_player: bool = true) -> void:
	node_to_close.hide()
	current_ui = null
	if activate_player:
		PlayerStats.change_state(PlayerStats.states.walk)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func close_all(activate_player: bool = true) -> void:
	for node in ui_nodes:
		node.hide()
	current_ui = null
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


func stop_audio() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
