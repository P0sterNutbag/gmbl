extends Encounter

var time_left := 30.0
var timer_started: bool
@onready var transition_timer: Timer = $TransitionTimer
@onready var timer_label: Label = $FpsUi/Timer


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot") and !timer_started:
		timer_started = true
		timer_label.show()
	if timer_started:
		time_left -= delta
		timer_label.text = "00:" + str(snapped(time_left, 0.01))
	if time_left <= 0.0:
		timer_label.hide()
		Globals.survival_ui.create_notification("Time's up")
		transition_timer.start()
		set_process(false)
	var targets = get_tree().get_nodes_in_group("targets")
	if targets.size() == 0 and time_left > 0.0:
		timer_label.hide()
		Globals.survival_ui.create_notification("Victory!")
		Globals.survival_ui.create_notification("You recieved $50")
		PlayerStats.inventory.money += 50
		PlayerStats.shooting_level += 1
		transition_timer.start()
		set_process(false)


func _exit_tree() -> void:
	if Globals.overworld:
		Globals.overworld.player_spawn_vector *= -1


func _on_transition_timer_timeout() -> void:
	SceneManager.start_scene_transition(Globals.overworld, false, false, true)


func _on_player_reload_finished() -> void:
	PlayerStats.inventory.add_item(Globals.player.gun.ammo_item)
