extends Menu


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = false
		queue_free()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")
	queue_free()
