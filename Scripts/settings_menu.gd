extends Menu


var overlay: CanvasLayer


func _ready() -> void:
	overlay = get_tree().root.get_node("Overlay")
	#_on_master_h_slider_value_changed(config.get_value("settings", "master_volume", 50))
	#_on_music_h_slider_value_changed(config.get_value("settings", "music_volume", 50))
	#_on_sfx_h_slider_value_changed(config.get_value("settings", "sfx_volume", 50))
	#_on_warp_toggled(config.get_value("settings", "warp_on", true))
	#_on_crt_toggled(config.get_value("settings", "crt_on", true))
	#_on_crosshair_option_changed(config.get_value("settings", "crosshair_type", 0))
	#_on_aim_sensitivity_h_slider_value_changed(config.get_value("settings", "mouse_sensitivity", 0.5))


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
	PlayerStats.sensitivity_modifier = value / 50
	ConfigManager.file.set_value("settings", "mouse_sensitivity", value / 50)
	ConfigManager.save()
