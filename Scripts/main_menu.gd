extends Menu

@onready var resume_button: MenuItem = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MenuItem
@onready var settings_menu: PanelContainer = $SettingsMenu
@onready var main_menu: PanelContainer = $PanelContainer
@onready var color_rect: ColorRect = $ColorRect
@onready var logo: TextureRect = $ColorRect/TextureRect


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Globals.overworld:
		Globals.overworld.queue_free()
	if !SaveController.save_file_exists():
		resume_button.visible = false
	var show_intro = !SceneManager.animation_player.is_playing()
	if show_intro:
		color_rect.show()
		var tween = create_tween()
		tween.tween_interval(1)
		tween.tween_property(logo, "modulate:a", 0, 0.5)
		tween.tween_interval(0.25)
		tween.tween_property(color_rect, "modulate:a", 0, 0.75)
		await tween.finished
	activate()


func _on_menu_item_pressed() -> void:
	SceneManager.load_on_enter = true
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn")


func _on_menu_item_2_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_menu_item_3_pressed() -> void:
	settings_menu.activate()
	main_menu.hide()


func _on_menu_item_4_pressed() -> void:
	get_tree().quit()


func _on_settings_menu_hidden() -> void:
	main_menu.show()
	activate()
