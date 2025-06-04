extends CharacterBody3D
class_name Enemy

@export var strafe_change := 0.2
@export var items_to_drop: Array[PackedScene]
enum guns {shotgun, ak47, sniper, pistol}
@export var gun_index: guns
enum teams {enemies, allies}
@export var team: teams = teams.enemies
@export var follow_target: Node3D
enum states {idle, investigate, attack, search, strafe, hurt, reload, camp, dead}
var state = states.idle
var walk_speed := 1.5
var run_speed := 3.0
var time_to_detect_max := 1.5
var camp_chance := 0.5
var camp_time := 5
var camp_time_min := 5
var camp_time_max := 10
var time_to_detect: float = time_to_detect_max
var time_since_bleed: float
var time_since_detect: float
var range := 100
var path_index: int
var is_new_state: bool
var on_alert: bool
var gun: Node3D
var damage_position: Vector3
var last_seen_position: Vector3
var target: Node3D
var guns_dict: Dictionary = {
	0 : [preload("res://Scenes/Guns/shotgun.tscn"), preload("res://Scenes/Items/Guns/shotgun.tscn")],
	1 : [preload("res://Scenes/Guns/ak47.tscn"), preload("res://Scenes/Items/Guns/assault_rifle.tscn")],
	2 : [preload("res://Scenes/Guns/sniper.tscn"), preload("res://Scenes/Items/Guns/sniper_rifle.tscn")],
	3 : [preload("res://Scenes/Guns/pistol.tscn"), preload("res://Scenes/Items/Guns/pistol.tscn")],
}
@onready var detection = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var return_to_idle_timer: Timer = $ReturnToIdleTimer
@onready var path_wait_timer: Timer = $PathWaitTimer
@onready var right_hand: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var shoot_component: Node = $ShootComponent
@onready var gun_holder: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var shoot_timer: Timer = $ShootTimer
signal shoot


func _ready() -> void:
	gun = guns_dict[gun_index][0].instantiate()
	gun_holder.add_child(gun)
	gun.bullet_stats.collision_mask = 4
	shoot_component.firepoint = gun.fire_point
	shoot_component.tracer_firepoint = gun.fire_point
	shoot_component.bullet_stats = gun.bullet_stats
	shoot_timer.wait_time = gun.fire_timer
	items_to_drop.append(guns_dict[gun_index][1])
	shoot.connect($ShootComponent._on_shoot)
	shoot.connect(gun._on_shoot)
	await get_tree().create_timer(0.5)
	if team == teams.allies:
		detection.targets = get_tree().get_nodes_in_group("enemies")
		shoot_component.bullet_stats.collision_mask = 3
	elif team == teams.enemies:
		detection.targets = get_tree().get_nodes_in_group("allies")
		shoot_component.bullet_stats.collision_mask = 4
	# set style
	


func _physics_process(delta: float) -> void:
	$Label3D.text = str(state)
	match state:
		states.idle:
			if is_new_state:
				on_alert = false
				velocity = Vector3.ZERO
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
				velocity = Vector3.ZERO
				is_new_state = false
			
			# stop moving
			velocity = Vector3.ZERO
			
			# detect target
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
				if !target:
					if randf() <= camp_chance:
						change_state(states.camp)
					else:
						#navigation_agent.set_target_position(last_seen_position)
						change_state(states.search)
					return
				anim_player.play("Fire")
				velocity = Vector3.ZERO
				is_new_state = false
			
			#if !target or target.state == states.dead:
				#target = null
				#change_state(states.investigate)
				#return
			
			# look at target
			if target:
				last_seen_position = target.global_position
				look_at_position(last_seen_position)
				shoot_component.firepoint.look_at(target.global_position + Vector3.UP * 1)
			
			# get into range
			#if target and global_position.distance_to(target.global_position) > range:
				#navigation_agent.set_target_position(target.global_position)
				#follow_path(run_speed)
			#else:
				#velocity = Vector3.ZERO
			
			# switch to search
			if !target: #!detection.can_see_target(target):
				time_since_detect += delta
				if time_since_detect >= 3:
					if randf() <= camp_chance:
						change_state(states.camp)
					else:
						#navigation_agent.set_target_position(last_seen_position)
						change_state(states.search)
			else:
				time_since_detect = 0
			
			# animate 
			#if velocity == Vector3.ZERO:
				#if gun.ammo > 0:
					#anim_player.play("Fire")
				#else:
					#anim_player.play("Idle")
			#else:
				#anim_player.play("WalkPoint")
		
		states.reload:
			if is_new_state:
				anim_player.play("Reload")
				is_new_state = false
		
		states.camp:
			if is_new_state:
				velocity = Vector3.ZERO
				time_since_detect = 0
				camp_time = randf_range(camp_time_min, camp_time_max)
				anim_player.play("IdlePoint")
				is_new_state = false
			
			if target:
				change_state(states.attack)
			
			time_since_detect += delta
			if time_since_detect > camp_time:
				if last_seen_position != Vector3.ZERO:
					#navigation_agent.set_target_position(last_seen_position)
					change_state(states.search)
				else:
					change_state(states.investigate)
			
		states.search:
			if is_new_state:
				if last_seen_position == Vector3.ZERO:
					change_state(states.investigate)
					return
				navigation_agent.set_target_position(last_seen_position)
				is_new_state = false
			
			# go to last seen position
			follow_path(run_speed)
			
			# return to attack
			if target:
				change_state(states.investigate)
			
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
				look_at_position(last_seen_position)
				change_state(states.attack)
			
			# animate
			if velocity == Vector3.ZERO:
				anim_player.play("Idle")
			else:
				anim_player.play("Run")
		
		states.hurt:
			pass
		
		states.dead:
			pass
		
	# Add gravity and move
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
	if state != states.dead:
		target = detection.get_visible_target()


func _process(delta: float) -> void:
	time_since_bleed += delta


func change_state(new_state: states):
	if state == new_state:
		return
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
	shoot_timer.start()


func on_noise_heard(noise_position: Vector3, event_creator: Node):
	pass
	if event_creator and event_creator.is_in_group(get_groups()[0]):
		return
	if state == states.dead or state == states.hurt:
		return
	on_alert = true
	if state == states.idle:
		last_seen_position = noise_position
		#navigation_agent.set_target_position(noise_position)
		#target = event_creator
		change_state(states.investigate)
	elif state == states.investigate:
		time_to_detect -= 0.5
	look_at_position(noise_position)


func _on_damaged(hit_position: Vector3, hit_direction: Vector3) -> void:
	velocity = Vector3.ZERO
	damage_position = hit_position
	if time_since_bleed < 0.1:
		return
	time_since_bleed = 0
	var blood_scene = load("res://Scenes/Particles/bloodspray.tscn")
	var blood = Globals.create_particle(blood_scene, hit_position)
	if blood != null:
		blood.set_deferred("rotation", Vector3(0, hit_direction.y, 0))
		blood.set_deferred("emitting", true)
	if state == states.dead:
		return
	anim_player.play("HitReaction")
	change_state(states.hurt)


func _on_death() -> void:
	if !gun:
		return 
	for i in items_to_drop:
		var inst = i.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		inst.set_deferred("global_position", right_hand.global_position)
		inst.apply_impulse.call_deferred(Vector3(randf_range(-2, 2), 5, randf_range(-2, 2)))
		#inst.apply_torque(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))
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
		change_state(states.investigate)
	elif state == states.strafe:
		change_state(states.attack)


func _on_return_to_idle_timer_timeout() -> void:
	if state == states.investigate and !detection.get_visible_target():
		if on_alert:
			change_state(states.search)
		else:
			change_state(states.idle)


func _on_path_wait_timer_timeout() -> void:
	if get_parent() is Path3D:
		path_index = wrap(path_index + 1, 0, get_parent().curve.point_count)


#func _on_shoot_finished() -> void:
	## switch to strafe
	#if randf_range(0, 1) <= strafe_change:
		#change_state(states.strafe)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("HitReaction"):
		look_at_position(damage_position)
		change_state(states.attack)
	elif anim_name == "Fire":
		#emit_shoot()
		gun.ammo -= 1
		if gun.ammo <= 0:
			gun.ammo = gun.max_ammo
			change_state(states.reload)
			return
		if randf_range(0, 1) <= strafe_change:
			change_state(states.strafe)
		else:
			anim_player.play("Fire")
	elif anim_name == "Reload":
		if target:
			look_at_position(target.global_position)
		change_state(states.attack)


func _on_shoot_timer_timeout() -> void:
	if anim_player.current_animation == "Fire":
		anim_player.advance(anim_player.current_animation.length())
