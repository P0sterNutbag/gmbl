extends Encounter

@onready var transition_timer: Timer = $TransitionTimer
var time_left = 30.0

func _process(delta: float) -> void:
	time_left -= delta
	if time_left <= 0.0:
		Globals.survival_ui.create_notification("Time's up")
		transition_timer.start()
		set_process(false)
	var targets = get_tree().get_nodes_in_group("targets")
	if targets.size() == 0 and time_left > 0.0:
		Globals.survival_ui.create_notification("Victory!")
		Globals.survival_ui.create_notification("You recieved $100")
		PlayerStats.inventory.money += 100
		PlayerStats.shooting_level += 1
		transition_timer.start()
		set_process(false)


func _exit_tree() -> void:
	if Globals.overworld:
		Globals.overworld.player_spawn_vector *= -1


func _on_transition_timer_timeout() -> void:
	SceneManager.start_scene_transition(Globals.overworld, false, false, true)
