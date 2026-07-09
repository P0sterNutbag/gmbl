extends Encounter

var enemies: Array
@onready var transition_timer: Timer = $TransitionTimer


func _process(_delta: float) -> void:
	if enemies.size() <= 0:
		return
	var all_dead := true
	for enemy in enemies:
		if enemy.state != Npc.states.dead:
			all_dead = false
	if all_dead:
		Globals.survival_ui.create_notification("Victory!")
		Globals.survival_ui.create_notification("You recieved $100")
		PlayerStats.inventory.money += 100
		transition_timer.start()
		set_process(false)


#func _on_enemy_spawner_enemies_spawned() -> void:
	#await get_tree().process_frame
	#enemies = get_tree().get_nodes_in_group("enemies")
	#for enemy in enemies:
		#enemy.last_seen_position = Globals.player.global_position
		#enemy.change_state(Npc.states.search)


func _on_transition_timer_timeout() -> void:
	SceneManager.start_scene_transition(Globals.overworld, false, false, true)
