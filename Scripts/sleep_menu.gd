extends VBoxContainer

@onready var h_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider
signal sleep_finished


func go_to_sleep(time_to_skip: float = 0.5):
	hide()
	var enemies := []
	enemies.append_array(get_tree().get_nodes_in_group("enemies"))
	enemies.append_array(get_tree().get_nodes_in_group("overworld_npcs"))
	for enemy in enemies:
		if enemy.target == Globals.player or enemy.global_position.distance_to(Globals.player.global_position) < 25.0:
			Globals.survival_ui.create_notification("Unable to sleep with enemies nearby")
			return
		if get_tree().current_scene != Globals.overworld and enemy.global_position.distance_to(Globals.player.global_position) < 25.0:
			Globals.survival_ui.create_notification("Unable to sleep with enemies nearby")
			return
	var tween = create_tween()
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_in"))
	tween.tween_callback(DayNightCycle.skip_to_time.bind(time_to_skip))
	tween.tween_callback(SceneManager.animation_player.play.bind("fade_out")).set_delay(2)
	tween.tween_callback(progress_npcs)
	tween.tween_property(PlayerStats, "sleep", PlayerStats.max_sleep, 0)
	tween.tween_property(PlayerStats, "soberness", PlayerStats.max_soberness, 0)
	tween.tween_callback(PlayerStats.decrease_thirst.bind(-0.3))
	tween.tween_callback(PlayerStats.decrease_hunger.bind(-0.3))
	tween.tween_property(Globals.player.hitbox, "hp", Globals.player.hitbox.hp + 0.5, 0)
	await tween.finished
	sleep_finished.emit()


func progress_npcs() -> void:
	for npc in get_tree().get_nodes_in_group("overworld npcs"):
		if npc.state == npc.states.battle:
			continue
		var target_pos = (npc.global_position + npc.navigation_agent.get_final_position()) / 2
		target_pos.y = Globals.get_heightmap_position(target_pos)
		npc.global_position = target_pos
	for npc in get_tree().get_nodes_in_group("enemies"):
		if npc.state == npc.states.walk:
			var target_pos = (npc.global_position + npc.navigation_agent.get_final_position()) / 2
			target_pos.y = Globals.get_heightmap_position(target_pos)
			npc.global_position = target_pos


func _on_visibility_changed() -> void:
	if visible:
		h_slider.value = 8
		h_slider.get_parent()._on_h_slider_value_changed(h_slider.value)


func _on_sleep_pressed() -> void:
	go_to_sleep(h_slider.value / 24)
	await sleep_finished
	UiController.close_interface(self)


func _on_exit_pressed() -> void:
	UiController.close_interface(self)
