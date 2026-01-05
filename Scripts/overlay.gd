extends CanvasLayer

var crt_on: bool = true
var warp_on: bool = true
@onready var crt: ColorRect = $CRT
@onready var warp: ColorRect = $Warp
@onready var mouse: TextureRect = $Mouse


func _process(_delta: float) -> void:
	mouse.visible = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN
	mouse.global_position = get_viewport().get_mouse_position()


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
