extends Menu


#func _process(_delta: float) -> void:
	#if !visible:
		#return
	#if Input.is_action_just_pressed("ui_cancel"):
		#hide()


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
