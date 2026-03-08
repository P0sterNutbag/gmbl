extends Menu

@onready var kills: Label = %Kills
@onready var level: Label = %Level
@onready var progress_bar: ProgressBar = %LevelBar
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer3/VBoxContainer
@onready var time: Label = %Time
const PROGRESS_AWARD_MESSAGE = preload("uid://yjunk2cfke0y")


func activate():
	super.activate()
	#var old_xp = ProgressManager.progress_data.xp
	#var old_level = ProgressManager.progress_data.level
	#ProgressManager.apply_progress()
	#var new_xp = ProgressManager.progress_data.xp
	#var new_level = ProgressManager.progress_data.level
	##tween.tween_property(kills, "text", "Kills: " + str(ProgressManager.kills), 1)
	##tween.tween_property(level, "text", "Level: " + str(ProgressManager.progress_data.level))
	##kills.text = "Kills: " + str(ProgressManager.kills)
	##level.text = "Level: " + str(old_level)
	#progress_bar.value = old_xp
	#for i in range(old_level, new_level+1):
		#progress_bar.value = old_xp
		#var target_xp = new_xp
		#if i - new_level != 0:
			#target_xp = 100
		#var tween = create_tween()
		#tween.tween_property(progress_bar, "value", target_xp, 1)
		#if target_xp == 100:
			#tween.tween_property(level, "text", "Level: " + str(i+1), 0)
		#await tween.finished
		#old_xp = 0
	#for award in ProgressManager.awards:
		#var inst = PROGRESS_AWARD_MESSAGE.instantiate()
		#v_box_container.add_child(inst)
		#inst.text = "+" + award.title + " added to starting gear."
	#progress_bar.value = ProgressManager.progress_data.xp


func _on_visibility_changed() -> void:
	if visible:
		activate()


func _on_continue_pressed() -> void:
	#if Globals.overworld:
		#Globals.overworld.queue_free()
	SceneManager.start_scene_transition("res://Scenes/UI/Levels/character_creation.tscn")
	Globals.overworld.player_died = true
	#SceneManager.start_scene_transition(Globals.overworld)


func _on_quit_pressed() -> void:
	SceneManager.start_scene_transition("res://Scenes/UI/main_menu.tscn")


func _on_quit_2_pressed() -> void:
	get_tree().quit()
