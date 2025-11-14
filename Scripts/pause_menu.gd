extends Menu


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			get_parent().visible = false


func activate() -> void:
	super.activate()
	get_tree().paused = true


func _on_resume_pressed() -> void:
	UiController.close_interface(self)
	#get_tree().paused = false
	#get_parent().visibe = false


func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	#SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")
	#queue_free()
