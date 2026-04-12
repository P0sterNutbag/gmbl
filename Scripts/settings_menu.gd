extends Menu

var overlay: CanvasLayer
@onready var resolution: Button = $MarginContainer/VBoxContainer/VBoxContainer/Resolution
@onready var fullscreen: Button = $MarginContainer/VBoxContainer/VBoxContainer/Fullscreen
@onready var volume: SliderButton = $MarginContainer/VBoxContainer/VBoxContainer/Volume
@onready var music_volume: SliderButton = $MarginContainer/VBoxContainer/VBoxContainer/MusicVolume
@onready var sfx_volume: SliderButton = $MarginContainer/VBoxContainer/VBoxContainer/SfxVolume
@onready var aim_sensitivity: SliderButton = $MarginContainer/VBoxContainer/VBoxContainer/AimSensitivity
@onready var crt: Button = $MarginContainer/VBoxContainer/VBoxContainer/CRT
@onready var warp: Button = $MarginContainer/VBoxContainer/VBoxContainer/Warp
@onready var crosshair: Button = $MarginContainer/VBoxContainer/VBoxContainer/Crosshair
@onready var aspect_ratio: Button = $MarginContainer/VBoxContainer/VBoxContainer/AspectRatio
@onready var hide_hud: Button = $MarginContainer/VBoxContainer/VBoxContainer/HideHud


func _ready() -> void:
	overlay = get_tree().root.get_node("Overlay")
	if !Globals.overworld:
		set_all_settings()


func set_all_settings() -> void:
	var is_fullscreen = ConfigManager.file.get_value("settings", "fullscreen", true)
	fullscreen.toggled.emit(is_fullscreen)
	var aspect = ConfigManager.file.get_value("settings", "aspect", 1)
	aspect_ratio.set_index_by_value(aspect)
	var res = ConfigManager.file.get_value("settings", "resolution", Vector2i(1920, 1080))
	resolution.set_index_by_value(res)
	var vol = ConfigManager.file.get_value("settings", "master_volume", 50)
	volume.h_slider.value = vol
	var mv = ConfigManager.file.get_value("settings", "music_volume", 50)
	music_volume.h_slider.value = mv
	var sv = ConfigManager.file.get_value("settings", "sfx_volume", 50)
	sfx_volume.h_slider.value = sv
	var sens = ConfigManager.file.get_value("settings", "mouse_sensitivity", 50)
	aim_sensitivity.h_slider.value = sens
	var crt_on = ConfigManager.file.get_value("settings", "crt_on", true)
	crt.toggled.emit(crt_on)
	var warp_on = ConfigManager.file.get_value("settings", "warp_on", true)
	warp.toggled.emit(warp_on)
	var cross = ConfigManager.file.get_value("settings", "crosshair_type", 0)
	crosshair.set_index_by_value(cross)
	var hud = ConfigManager.file.get_value("settings", "hide_hud", false)
	hide_hud.toggled.emit(hud)


func _on_master_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	ConfigManager.file.set_value("settings", "master_volume", value)
	ConfigManager.save()


func _on_music_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	ConfigManager.file.set_value("settings", "music_volume", value)
	ConfigManager.save()


func _on_sfx_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	ConfigManager.file.set_value("settings", "sfx_volume", value)
	ConfigManager.save()


func _on_back_pressed() -> void:
	hide()


func _on_warp_toggled(toggled_on: bool) -> void:
	overlay.toggle_warp(toggled_on)
	ConfigManager.file.set_value("settings", "warp_on", toggled_on)
	ConfigManager.save()


func _on_crt_toggled(toggled_on: bool) -> void:
	overlay.toggle_crt(toggled_on)
	ConfigManager.file.set_value("settings", "crt_on", toggled_on)
	ConfigManager.save()


func _on_crosshair_option_changed(value: Variant) -> void:
	call("change_crosshair", value)


func change_crosshair(index: int) -> void:
	Globals.crosshair_type = index as Globals.crosshairs
	ConfigManager.file.set_value("settings", "crosshair_type", index)
	ConfigManager.save()


func _on_aim_sensitivity_h_slider_value_changed(value: float) -> void:
	var modifier = value / 50
	PlayerStats.sensitivity_modifier = modifier
	ConfigManager.file.set_value("settings", "mouse_sensitivity", value)
	ConfigManager.save()


func _on_resolution_option_changed(value: Variant) -> void:
	if !resolution.visible:
		return
	DisplayServer.window_set_size(Vector2i(value))
	DisplayServer.window_set_position(DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() - Vector2i(value)) / 2)
	ConfigManager.file.set_value("settings", "resolution", Vector2i(value))
	ConfigManager.save()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	var window = get_window()
	if toggled_on:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		resolution.hide()
	else:
		window.mode = Window.MODE_WINDOWED
		resolution.show()
	ConfigManager.file.set_value("settings", "fullscreen", toggled_on)
	ConfigManager.save()


func _on_aspect_ratio_option_changed(value: Variant) -> void:
	if value == 0:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		overlay.set_resolution(Vector2(720.0, 540.0))
	elif value == 1:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_HEIGHT
		overlay.set_resolution(Vector2(960.0, 540.0))
	ConfigManager.file.set_value("settings", "aspect", value)
	ConfigManager.save()


func _on_hide_hud_toggled(toggled_on: bool) -> void:
	ConfigManager.file.set_value("settings", "hide_hud", toggled_on)
	ConfigManager.save()
