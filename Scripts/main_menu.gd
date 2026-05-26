extends Menu

@onready var resume_button: MenuItem = $PanelContainer/MarginContainer/VBoxContainer/Continue
@onready var settings_menu: Control = $SettingsMenu
@onready var main_menu: PanelContainer = $PanelContainer
@onready var color_rect: ColorRect = $ColorRect
@onready var logo: TextureRect = $ColorRect/TextureRect
@onready var confirmation_menu: Control = $ConfirmationMenu
@onready var confirmation_menu2: Control = $ConfirmationMenu2
@onready var difficulty_options: VBoxContainer = $DifficultyOptions
@onready var normal_description: Label = %NormalDescription
@onready var hard_description: Label = %HardDescription
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
		color_rect.hide()
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
		if !main_menu.visible and color_rect.modulate.a <= 0 and !settings_menu.visible and !confirmation_menu.visible and !confirmation_menu2.visible and !difficulty_options.visible:
			main_menu.show()
			activate()


func _on_menu_item_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld_demo.tscn", false, true)


func _on_menu_item_2_pressed() -> void:
	main_menu.hide()
	if resume_button.visible:
		confirmation_menu.show()
	else:
		difficulty_options.show()
		#SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_menu_item_3_pressed() -> void:
	settings_menu.activate()
	main_menu.hide()


func _on_menu_item_4_pressed() -> void:
	confirmation_menu2.show()
	main_menu.hide()


func _on_settings_menu_visibility_changed() -> void:
	if !settings_menu.visible:
		main_menu.show()
		activate()


func _on_yes_pressed() -> void:
	#main_menu.show()
	confirmation_menu.hide()
	difficulty_options.show()


func _on_no_pressed() -> void:
	main_menu.show()
	confirmation_menu.hide()


func _on_yes2_pressed() -> void:
	var steam_url = "steam://store/4304500"
	OS.shell_open(steam_url)
	get_tree().quit()


func _on_no2_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	main_menu.show()
	confirmation_menu2.hide()


func _on_normal_pressed() -> void:
	difficulty_options.hide()
	ConfigManager.file.set_value("settings", "difficulty", 0)
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_hard_pressed() -> void:
	difficulty_options.hide()
	ConfigManager.file.set_value("settings", "difficulty", 1)
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_exit_difficulty_options_pressed() -> void:
	difficulty_options.hide()
	main_menu.show()


func _on_normal_difficulty_focus_entered() -> void:
	normal_description.show()
	hard_description.hide()


func _on_hard_focus_entered() -> void:
	normal_description.hide()
	hard_description.show()
