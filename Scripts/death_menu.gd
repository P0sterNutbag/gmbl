extends Menu

@onready var kills: Label = %Kills
@onready var level: Label = %Level
@onready var progress_bar: ProgressBar = %LevelBar
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer3/VBoxContainer
@onready var time: Label = %Time
@onready var continue_button: MenuItem = %Continue
const PROGRESS_AWARD_MESSAGE = preload("uid://yjunk2cfke0y")


func _on_visibility_changed() -> void:
	if visible:
		continue_button.visible = ConfigManager.file.get_value("settings", "difficulty", 0) == 0


func _on_continue_pressed() -> void:
	if Globals.overworld:
		Globals.overworld.queue_free()
	SceneManager.start_scene_transition("res://Scenes/Overworld/overworld.tscn", false, true)


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()
