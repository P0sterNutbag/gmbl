extends CanvasLayer

var crt_on: bool = true
var warp_on: bool = true
@onready var crt: ColorRect = $CRT
@onready var warp: ColorRect = $Warp
@onready var mouse: TextureRect = $Mouse


func _process(_delta: float) -> void:
	mouse.visible = Input.mouse_mode == Input.MOUSE_MODE_HIDDEN
	mouse.global_position = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("jump"):
		if crt.material.get_shader_parameter("compression_on") == 0:
			crt.material.set_shader_parameter("compression_on", 1)
		else:
			crt.material.set_shader_parameter("compression_on", 0)
	#warp_on = ConfigManager.file.get_value("settings", "warp_on", warp_on)
	#toggle_warp(warp_on)
	#crt_on = ConfigManager.file.get_value("settings", "crt_on", crt_on)
	#toggle_crt(crt_on)


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
