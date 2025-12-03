extends Menu


func _on_continue_pressed() -> void:
	if Globals.overworld:
		Globals.overworld.queue_free()
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()
