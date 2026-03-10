extends Enemy
class_name Ally

var follow_speed = 5.9

func state_idle(_delta) -> void:
	change_state(states.walk)


func state_walk(delta) -> void:
	if Globals.player:
		if global_position.distance_to(Globals.player.global_position) > 3:
			navigation_agent.set_target_position(Globals.player.global_position)
	follow_path(follow_speed)
	# switch to investigate
	if target != null:
		time_to_see += delta
		if time_to_see > time_to_see_max:
			time_to_see = 0
			change_state(states.investigate)
	# animate
	if abs(velocity) == Vector3.ZERO:
		anim_player.play("Idle")
	elif velocity.length() >= run_speed-1:
		anim_player.play("Run")
	else:
		anim_player.play("Walk")


func _on_navigation_agent_3d_navigation_finished() -> void:
	if state == states.search:
		change_state(states.investigate)
	elif state == states.strafe:
		look_at_position(last_seen_position)
		change_state(states.shoot)
	elif state == states.find_cover:
		look_at(last_seen_position)
		change_state(states.camp)
	elif state == states.walk:
		velocity = Vector3.ZERO
