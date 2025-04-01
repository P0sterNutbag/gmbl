extends CharacterBody3D

enum states {idle, investigate, attack, search}
var state = states.idle
var walk_speed := 1.5
var run_speed := 3.0
var time_to_detect_max := 1.5
var time_to_detect: float = time_to_detect_max
var range := 100
var path_index: int
var target: Node3D
@onready var firepoint = $EnemyModel/Armature/Skeleton3D/BoneAttachment3D/AssaultRifle_3/FirePoint
@onready var detection = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/AnimationPlayer
@onready var return_to_idle_timer: Timer = $ReturnToIdleTimer
@onready var path_wait_timer: Timer = $PathWaitTimer
signal shoot


func _ready() -> void:
	target = Globals.player
	shoot.connect($ShootComponent._on_shoot)


func _physics_process(delta: float) -> void:
	match state:
		states.idle:
			# return to path
			var parent = get_parent()
			if parent is Path3D:
				var next_point = parent.global_position + parent.curve.get_point_position(path_index)
				if navigation_agent.target_position != next_point:
					navigation_agent.set_target_position(next_point)
				follow_path()

			# switch to investigate
			if detection.can_see_target():
				state = states.investigate
				time_to_detect = time_to_detect_max
				print("target spotted")
			
			# animate
			if velocity == Vector3.ZERO:
				anim_player.play("Idle")
			else:
				anim_player.play("Walk")
			
		states.investigate:
			# stop moving
			velocity = Vector3.ZERO
			print("investigating")
			
			# detect player
			if detection.can_see_target():
				look_at_position(target.global_position)
				var dis_to_target = global_position.distance_to(target.global_position)
				time_to_detect -= (20 / dis_to_target) * delta
				if time_to_detect <= 0:
					state = states.attack
					print("attack from investigate!")
			else:
				if return_to_idle_timer.wait_time == 0:
					return_to_idle_timer.start()
				#state = states.idle
			anim_player.play("Idle")
			
		states.attack:
			# look at player
			look_at_position(target.global_position)
			firepoint.look_at(target.global_position + Vector3.UP * 0.25)
			
			# get into range
			if global_position.distance_to(target.global_position) > range:
				navigation_agent.set_target_position(target.global_position)
				follow_path(run_speed)
			else:
				velocity = Vector3.ZERO
			
			# switch to search state
			if !detection.can_see_target():
				navigation_agent.set_target_position(target.global_position)
				state = states.search
				print("target lost")
			
			# animate 
			if velocity == Vector3.ZERO:
				anim_player.play("Shoot")
			else:
				anim_player.play("Walk")
			
		states.search:
			# go to last seen position
			follow_path(run_speed)
			print("searching")
			
			# return to attack
			if detection.can_see_target():
				state = states.attack
				velocity = Vector3.ZERO
				print("attack from search!")
			
			# animate
			anim_player.play("Walk")
			
	# Add gravity and move
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path(speed: float = walk_speed):
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	next_path_position.y = global_position.y
	if global_position.distance_to(next_path_position) < 0.1:
		velocity = Vector3.ZERO
		return
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	velocity = new_velocity
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func on_noise_heard(noise_position: Vector3):
	if state != states.attack and state != states.search:
		state = states.investigate
	look_at_position(noise_position)
	navigation_agent.set_target_position(noise_position)
	await get_tree().create_timer(1).timeout
	if state != states.attack and state != states.search:
		state = states.search


func _on_damaged() -> void:
	if state != states.attack:
		state = states.attack


func _on_death() -> void:
	queue_free()


func _on_navigation_agent_3d_navigation_finished() -> void:
	if state == states.idle:
		path_wait_timer.start()
		print("path point reached")
	elif state == states.search:
		state = states.idle
		print("target not found, return to idle")


func _on_return_to_idle_timer_timeout() -> void:
	if state == states.investigate and !detection.can_see_player():
		state = "idle"


func _on_path_wait_timer_timeout() -> void:
	path_index = wrap(path_index + 1, 0, get_parent().curve.point_count)
