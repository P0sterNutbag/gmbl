extends Node

var fullscreen: bool:
	get: return ConfigManager.file.get_value("settings", "fullscreen", true)
var resolution: Vector2i:
	get: return ConfigManager.file.get_value("settings", "resolution", Vector2i(1920, 1080))
var master_volume: float:
	get: return ConfigManager.file.get_value("settings", "master_volume", 50)
var music_volume: float:
	get: return ConfigManager.file.get_value("settings", "music_volume", 50)
var sfx_volume: float:
	get: return ConfigManager.file.get_value("settings", "sfx_volume", 50)
var mouse_sentitivity: float:
	get: return ConfigManager.file.get_value("settings", "mouse_sensitivity", 50)
var crt: bool:
	get: return ConfigManager.file.get_value("settings", "crt_on", true)
var crosshair: int:
	get: return ConfigManager.file.get_value("settings", "crosshair_type", 0)
var show_ammo: bool:
	get: return ConfigManager.file.get_value("settings", "show_ammo", true)
var difficulty: int:
	get: return ConfigManager.file.get_value("settings", "difficulty", 0)
var save_difficulty: int
var overlay: CanvasLayer


func _ready() -> void:
	SaveController.load.connect(_on_load)
	overlay = get_tree().root.get_node("Overlay")
	apply_all_settings()


func apply_all_settings() -> void:
	set_fullscreen(fullscreen)
	set_resolution(resolution)
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	set_aim_sensitivity(mouse_sentitivity)
	set_crt(crt)
	set_crosshair(crosshair)
	set_hud(show_ammo)


func set_master_volume(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	ConfigManager.file.set_value("settings", "master_volume", value)
	ConfigManager.save()


func set_music_volume(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	ConfigManager.file.set_value("settings", "music_volume", value)
	ConfigManager.save()


func set_sfx_volume(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))
	ConfigManager.file.set_value("settings", "sfx_volume", value)
	ConfigManager.save()


func set_warp(value: bool) -> void:
	overlay.toggle_warp(value)
	ConfigManager.file.set_value("settings", "warp_on", value)
	ConfigManager.save()


func set_crt(value: bool) -> void:
	overlay.toggle_crt(value)
	ConfigManager.file.set_value("settings", "crt_on", value)
	ConfigManager.save()


func set_crosshair(index: int) -> void:
	Globals.crosshair_type = index as Globals.crosshairs
	ConfigManager.file.set_value("settings", "crosshair_type", index)
	ConfigManager.save()


func set_aim_sensitivity(value: float) -> void:
	var modifier = value / 50
	PlayerStats.sensitivity_modifier = modifier
	ConfigManager.file.set_value("settings", "mouse_sensitivity", value)
	ConfigManager.save()


func set_resolution(value: Variant) -> void:
	if ConfigManager.file.get_value("settings", "fullscreen", true):
		return
	DisplayServer.window_set_size(Vector2i(value))
	DisplayServer.window_set_position(DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() - Vector2i(value)) / 2)
	ConfigManager.file.set_value("settings", "resolution", Vector2i(value))
	ConfigManager.save()


func set_fullscreen(value: bool) -> void:
	var window = get_window()
	if value:
		window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
	ConfigManager.file.set_value("settings", "fullscreen", value)
	ConfigManager.save()


func set_aspect_ratio(value: Variant) -> void:
	if value == 0:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		overlay.set_resolution(Vector2(720.0, 540.0))
	elif value == 1:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_HEIGHT
		overlay.set_resolution(Vector2(960.0, 540.0))
	ConfigManager.file.set_value("settings", "aspect", value)
	ConfigManager.save()


func set_hud(value: bool) -> void:
	ConfigManager.file.set_value("settings", "show_ammo", value)
	ConfigManager.save()


func save() -> Dictionary:
	return {
		"save_difficulty" : difficulty,
	}


func _on_load() -> void:
	ConfigManager.file.set_value("settings", "difficulty", save_difficulty)
