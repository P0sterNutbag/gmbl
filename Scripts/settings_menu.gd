extends Menu


var overlay: CanvasLayer


func _ready() -> void:
	overlay = get_tree().root.get_node("Overlay")


func _on_volume_pressed() -> void:
	pass # Replace with function body.


func _on_master_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))


func _on_music_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))


func _on_sfx_h_slider_value_changed(value: float) -> void:
	var sfx_index= AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value / 100))


func _on_back_pressed() -> void:
	hide()


func _on_warp_toggled(toggled_on: bool) -> void:
	overlay.toggle_warp(toggled_on)


func _on_crt_toggled(toggled_on: bool) -> void:
	overlay.toggle_crt(toggled_on)


func _on_crosshair_option_changed(value: Variant) -> void:
	call("change_crosshair", value)


func change_crosshair(index: int) -> void:
	Globals.crosshair_type = index as Globals.crosshairs
