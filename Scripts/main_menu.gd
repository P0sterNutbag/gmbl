extends Menu

@onready var resume_button: MenuItem = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MenuItem
@onready var settings_menu: PanelContainer = $SettingsMenu
@onready var main_menu: MarginContainer = $PanelContainer/MarginContainer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if !SaveController.save_file_exists():
		resume_button.visible = false
	activate()


func _on_menu_item_pressed() -> void:
	SceneManager.load_on_enter = true
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn", true)


func _on_menu_item_2_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn")


func _on_menu_item_3_pressed() -> void:
	settings_menu.activate()
	main_menu.hide()


func _on_menu_item_4_pressed() -> void:
	get_tree().quit


func _on_settings_menu_hidden() -> void:
	main_menu.show()
