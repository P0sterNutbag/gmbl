extends Menu

@onready var pause_menu: PanelContainer = $PanelContainer
@onready var settings_menu: PanelContainer = $SettingsMenu
@onready var save_button: MenuItem = %SaveGame
@onready var confirmation_menu = $ConfirmationMenu
@onready var confirmation_menu2 = $ConfirmationMenu2
@onready var controls = $Controls


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !pause_menu.visible:
			confirmation_menu.hide()
			confirmation_menu2.hide()
			controls.hide()
			settings_menu.hide()
			pause_menu.show()


#func activate() -> void:
	#super.activate()
	#get_tree().paused = true


func _on_resume_pressed() -> void:
	UiController.close_interface(self)
	#get_tree().paused = false


func _on_settings_pressed() -> void:
	pause_menu.hide()
	#UiController.open_interface(settings_menu)
	settings_menu.show()


func _on_quit_pressed() -> void:
	#if get_tree().current_scene == Globals.overworld:
		#SaveController.save_data_to_file()
		#SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")
	#else:
	pause_menu.hide()
	confirmation_menu2.show()


func _on_quit_2_pressed() -> void:
	#SaveController.save_data_to_file()
	#await SaveController.save
	#get_tree().quit()
	confirmation_menu.show()
	pause_menu.hide()


func _on_settings_menu_hidden() -> void:
	settings_menu.hide()
	#UiController.open_interface(settings_menu)
	pause_menu.show()
	#UiController.open_interface(pause_menu)


func _on_panel_container_visibility_changed() -> void:
	if !is_inside_tree():
		return
	if visible:
		get_tree().paused = true
		if Globals.overworld and get_tree().current_scene == Globals.overworld:
			save_button.disabled = false
		else:
			save_button.disabled = true
	else:
		get_tree().paused = false


func _on_save_game_pressed() -> void:
	SaveController.save_data_to_file()


func _on_yes_pressed() -> void:
	get_tree().quit()


func _on_no_pressed() -> void:
	confirmation_menu.hide()
	pause_menu.show()


func _on_yes_pressed2() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/main_menu.tscn")


func _on_no_pressed2() -> void:
	confirmation_menu2.hide()
	pause_menu.show()


func _on_controls_pressed() -> void:
	pause_menu.hide()
	controls.show()


func _on_exit_controls_pressed() -> void:
	controls.hide()
	pause_menu.show()
