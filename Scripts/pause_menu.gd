extends Menu

@onready var pause_menu: PanelContainer = $PanelContainer
@onready var settings_menu: PanelContainer = $SettingsMenu
@onready var save_quit_button: MenuItem = %Quit


#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_cancel"):
		#if pause_menu.visible:
			#if get_tree().paused:
				#get_tree().paused = false
				##get_parent().visible = false


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
	if get_tree().current_scene == Globals.overworld:
		SaveController.save_data_to_file()
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	#SaveController.save_data_to_file()
	get_tree().quit()


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
	else:
		get_tree().paused = false
		#if Globals.overworld and get_tree().current_scene == Globals.overworld:
			#save_quit_button.show()
		#else:
			#save_quit_button.hide()
