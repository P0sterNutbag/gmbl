extends CharacterBody3D
class_name Enemy

@export var gun: Node3D
@export var strafe_change := 0.2
@export var items_to_drop: Array[PackedScene]
enum teams {enemies, allies}
@export var team: teams = teams.enemies
@export var follow_target: Node3D
enum states {idle, investigate, attack, search, strafe, hurt, dead}
var state = states.idle
var walk_speed := 1.5
var run_speed := 3.0
var time_to_detect_max := 1.5
var time_to_detect: float = time_to_detect_max
var time_since_bleed: float
var range := 100
var path_index: int
var is_new_state: bool
var on_alert: bool
var damage_position: Vector3
var target: Node3D
var firepoint: Node3D
var blood_particle: PackedScene
@onready var detection = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var return_to_idle_timer: Timer = $ReturnToIdleTimer
@onready var path_wait_timer: Timer = $PathWaitTimer
@onready var right_hand: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var shoot_component: Node = $ShootComponent
signal shoot


func _ready() -> void:
	#detection.targets.append(Globals.player)
	firepoint = gun.fire_point
	shoot.connect($ShootComponent._on_shoot)
	shoot.connect(gun._on_shoot)
	blood_particle = load("res://Scenes/Particles/bloodspray.tscn")
	await get_tree().create_timer(0.5)
	if team == teams.allies:
		detection.targets = get_tree().get_nodes_in_group("enemies")
		shoot_component.bullet_stats.collision_mask = 3
	elif team == teams.enemies:
		detection.targets = get_tree().get_nodes_in_group("allies")
		shoot_component.bullet_stats.collision_mask = 4


func _physics_process(delta: float) -> void:
	match state:
		states.idle:
			if is_new_state:
				on_alert = false
				is_new_state = false
			
			# return to path
			var parent = get_parent()
			if parent is Path3D:
				var next_point = parent.global_position + parent.curve.get_point_position(path_index)
				if navigation_agent.target_position != next_point:
					navigation_agent.set_target_position(next_point)
				follow_path()
			elif follow_target:
				navigation_agent.set_target_position(follow_target.global_position)
				follow_path(run_speed)
			
			# switch to investigate
			target = detection.get_visible_target()
			if target != null:
				change_state(states.investigate)
			
			# animate
			if abs(velocity) == Vector3.ZERO:
				anim_player.play("Idle")
			elif velocity.length() >= run_speed-1:
				anim_player.play("Run")
			else:
				anim_player.play("Walk")
			
		states.investigate:
			if is_new_state:
				time_to_detect = time_to_detect_max
				is_new_state = false
			
			# stop moving
			velocity = Vector3.ZERO
			
			# detect target
			target = detection.get_visible_target()
			if target:
				look_at_position(target.global_position)
				var dis_to_target = global_position.distance_to(target.global_position)
				time_to_detect -= (20 / dis_to_target) * delta
				if time_to_detect <= 0 or on_alert:
					change_state(states.attack)
			else:
				if return_to_idle_timer.time_left <= 0:
					return_to_idle_timer.start()
			anim_player.play("IdlePoint")
			
		states.attack:
			if is_new_state:
				on_alert = true
				is_new_state = false
			
			if !target or target.state == states.dead:
				target = null
				change_state(states.investigate)
				return
			
			# look at target
			look_at_position(target.global_position)
			firepoint.look_at(target.global_position + Vector3.UP * 1)
			
			# get into range
			if global_position.distance_to(target.global_position) > range:
				navigation_agent.set_target_position(target.global_position)
				follow_path(run_speed)
			else:
				velocity = Vector3.ZERO
			
			# switch to search
			if !detection.can_see_target(target):
				navigation_agent.set_target_position(target.global_position)
				change_state(states.search)
			
			# animate 
			if velocity == Vector3.ZERO:
				if gun.ammo > 0:
					anim_player.play("Fire")
				else:
					anim_player.play("Idle")
			else:
				anim_player.play("WalkPoint")
			
		states.search:
			# go to last seen position
			follow_path(run_speed)
			
			# return to attack
			#target = detection.get_visible_target()
			if detection.can_see_target(target):
				velocity = Vector3.ZERO
				change_state(states.attack)
			
			# animate
			anim_player.play("WalkPoint")
			
		states.strafe:
			# set new strafe position
			if is_new_state:
				var new_pos = global_position
				new_pos = global_position + Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
				navigation_agent.set_target_position(new_pos)
				is_new_state = false
			
			# run to new position
			follow_path(run_speed)
			
			# stop strafing
			if velocity.length() < 0.1:
				change_state(states.attack)
			
			# animate
			if velocity == Vector3.ZERO:
				anim_player.play("Idle")
			else:
				anim_player.play("Walk")
		
		states.hurt:
			pass
		
		states.dead:
			pass
		
	# Add gravity and move
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _process(delta: float) -> void:
	time_since_bleed += delta


func change_state(new_state: states):
	state = new_state
	is_new_state = true


func follow_path(speed: float = walk_speed):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	next_path_position.y = global_position.y
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	navigation_agent.set_velocity(velocity)
	velocity = new_velocity
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	var target_pos = pos
	target_pos.y = global_position.y
	if target_pos != global_position:
		look_at(target_pos, Vector3.UP)


func set_detection_targets():
	if team == teams.allies:
		detection.targets = get_tree().get_nodes_in_group("enemies").filter(func(i): return i.state != states.dead)
	elif team == teams.enemies:
		detection.targets = get_tree().get_nodes_in_group("allies").filter(func(i): return i.state != states.dead)


func emit_shoot() -> void:
	shoot.emit()


func on_noise_heard(noise_position: Vector3, event_creator: Node):
	if event_creator and event_creator.is_in_group(get_groups()[0]):
		return
	if state == states.dead or state == states.hurt:
		return
	if state == states.idle:
		navigation_agent.set_target_position(noise_position)
		target = event_creator
		change_state(states.search)
	elif state == states.investigate:
		time_to_detect -= 0.5
	look_at_position(noise_position)


func _on_damaged(hit_position: Vector3, hit_direction: Vector3) -> void:
	velocity = Vector3.ZERO
	damage_position = hit_position
	if time_since_bleed < 0.1:
		return
	time_since_bleed = 0
	var blood = blood_particle.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = hit_position
	blood.rotation.y = hit_direction.y
	blood.emitting = true
	if state == states.dead:
		return
	anim_player.play("HitReaction")
	change_state(states.hurt)


func _on_death() -> void:
	if !gun:
		return 
	for i in items_to_drop:
		var inst = i.instantiate()
		inst.global_position = right_hand.global_position
		inst.apply_impulse(Vector3(randf_range(-2, 2), 5, randf_range(-2, 2)))
		#inst.apply_torque(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))
		get_tree().current_scene.add_child(inst)
	gun.queue_free()
	velocity = Vector3.ZERO
	anim_player.play("Die")
	change_state(states.dead)
	if team == teams.allies:
		get_tree().call_group("enemies", "set_detection_targets")
	if team == teams.enemies:
		get_tree().call_group("allies", "set_detection_targets")


func _on_navigation_agent_3d_navigation_finished() -> void:
	if state == states.idle:
		path_wait_timer.start()
		velocity = Vector3.ZERO
	elif state == states.search:
		change_state(states.idle)
	elif state == states.strafe:
		change_state(states.attack)


func _on_return_to_idle_timer_timeout() -> void:
	if state == states.investigate and !detection.get_visible_target():
		change_state(states.idle)


func _on_path_wait_timer_timeout() -> void:
	if get_parent() is Path3D:
		path_index = wrap(path_index + 1, 0, get_parent().curve.point_count)


func _on_shoot_finished() -> void:
	# switch to strafe
	if randf_range(0, 1) <= strafe_change:
		change_state(states.strafe)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("HitReaction"):
		look_at_position(damage_position)
		change_state(states.attack)
	elif anim_name == "Fire":
		emit_shoot()
