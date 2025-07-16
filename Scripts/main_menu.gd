extends Menu


func _ready() -> void:
	activate()


func _on_menu_item_pressed() -> void:
	SceneManager.load_on_enter = true
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn", true)


func _on_menu_item_2_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn")


func _on_menu_item_3_pressed() -> void:
	pass # Replace with function body.


func _on_menu_item_4_pressed() -> void:
	get_tree().quit
