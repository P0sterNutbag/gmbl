extends Menu

@onready var resume_button: MenuItem = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/MenuItem
@onready var settings_menu: PanelContainer = $SettingsMenu
@onready var main_menu: PanelContainer = $PanelContainer
@onready var color_rect: ColorRect = $ColorRect
@onready var logo: TextureRect = $ColorRect/TextureRect
var logo_tween: Tween
var skip_intro: bool


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	main_menu.hide()
	if Globals.overworld:
		Globals.overworld.queue_free()
	if !SaveController.save_file_exists():
		resume_button.visible = false
	var show_intro = !SceneManager.animation_player.is_playing()
	if show_intro:
		color_rect.show()
		logo_tween = create_tween()
		logo_tween.tween_interval(1)
		logo_tween.tween_property(logo, "modulate:a", 0, 0.5)
		logo_tween.tween_interval(0.25)
		logo_tween.tween_property(color_rect, "modulate:a", 0, 0.75)
		await logo_tween.finished
	else:
		main_menu.show()
		activate()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if settings_menu.visible:
			settings_menu.hide()
			main_menu.show()
			activate()


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if !skip_intro and logo_tween and logo_tween.is_running():
			skip_intro = true
			logo_tween.kill()
			logo_tween = create_tween()
			logo_tween.tween_property(logo, "modulate:a", 0, 0.5)
			logo_tween.tween_property(color_rect, "modulate:a", 0, 0.5)
		if !main_menu.visible and color_rect.modulate.a <= 0 and !settings_menu.visible:
			main_menu.show()
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


func _on_settings_menu_visibility_changed() -> void:
	if !settings_menu.visible:
		main_menu.show()
		activate()
