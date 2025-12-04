extends Menu

@onready var kills: Label = $MarginContainer/VBoxContainer/Kills
@onready var level: Label = $MarginContainer/VBoxContainer/HBoxContainer/Level
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/ProgressBar


func activate():
	super.activate()
	ProgressManager.apply_progress()
	kills.text = "Kills: " + str(ProgressManager.kills)
	level.text = "Level: " + str(ProgressManager.progress_data.level)
	progress_bar.value = ProgressManager.progress_data.xp


func _on_visibility_changed() -> void:
	if visible:
		activate()


func _on_continue_pressed() -> void:
	if Globals.overworld:
		Globals.overworld.queue_free()
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()
