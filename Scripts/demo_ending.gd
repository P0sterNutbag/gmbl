extends CanvasLayer


func _on_wishlist_pressed() -> void:
	var steam_url = "steam://store/4304500"
	OS.shell_open(steam_url)


func _on_back_to_game_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld_demo.tscn")


func _on_exit_to_menu_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/main_menu.tscn")


func _on_exit_game_pressed() -> void:
	get_tree().quit()
