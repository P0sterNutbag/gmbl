extends CanvasLayer

var crt_on: bool = true
var warp_on: bool = true
var mouse_timer: float
@onready var crt: ColorRect = $CRT
@onready var warp: ColorRect = $Warp
@onready var mouse: TextureRect = $Mouse


func _process(delta: float) -> void:
	mouse.visible = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN
	mouse.global_position = get_viewport().get_mouse_position()
	if Globals.overworld and get_tree().current_scene == Globals.overworld and UiController.current_ui == null and Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		mouse_timer += delta
		if Input.get_last_mouse_velocity().abs() > Vector2.ZERO:
			mouse_timer = 0.0
		if mouse_timer > 3.0:
			mouse.hide()
		else:
			mouse.show()
	else:
		mouse_timer = 0.0


func toggle_warp(value: bool) -> void:
	warp_on = value
	if value:
		crt.material.set_shader_parameter("warp_amount", 0.005)
	else:
		crt.material.set_shader_parameter("warp_amount", 0)
	if !crt.visible:
		warp.visible = value


func toggle_crt(value: bool) -> void:
	crt_on = value
	crt.visible = value
	if warp_on:
		warp.visible = true


func set_resolution(new_res: Vector2) -> void:
	crt.material.set_shader_parameter("resolution", new_res)
