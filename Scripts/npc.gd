extends CharacterBody3D
class_name Enemy

@export var npc_data: NpcData
@export var title: String = "Enemy"
@export var strafe_change := 0.2
@export var items_to_drop: Array[PackedScene]
@export var potential_gun_items: Array[SpawnChanceResource]
@export var inventory: Inventory
@export var faction: FactionManager.factions
enum states {idle, investigate, shoot, search, strafe, hurt, reload, camp, dead, aim, walk, supress, find_cover, approach}
enum goals {guard, travel, follow, none}
var state = states.idle
var goal = goals.guard
var walk_speed := 1.5
var run_speed := 3.0
var time_to_detect_max := 0.5
var camp_chance := 0.1
var supress_change := 0.25
var camp_time := 5.0
var camp_time_min := 2.5
var camp_time_max := 10.0
var time_to_detect: float = time_to_detect_max
var time_since_detect: float
@export var time_to_see_max: float = 1.0
var time_to_see: float = 0.0
var day_range := 100
var night_range := 50
var path_index: int
var is_new_state: bool
var on_alert: bool
var is_starting_squad: bool
var open_fire: bool = true
var damage_position: Vector3
var damage_direction: Vector3
var last_seen_position: Vector3
var push_velocity: Vector3
var destination: Vector3
var state_functions: Dictionary
var target: Node3D
var gun: Node3D
var follow_target: Node3D
var bounty: Quest
var gun_item: EquipmentGun
@onready var detection = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var model = $EnemyModel
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var return_to_idle_timer: Timer = $ReturnToIdleTimer
@onready var path_wait_timer: Timer = $PathWaitTimer
@onready var right_hand: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var gun_holder: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var shoot_timer: Timer = $ShootTimer
@onready var health_component: HealthComponent = $Hitbox
@onready var aim_timer: Timer = $AimTimer
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var supress_timer: Timer = $SupressTimer
@onready var new_destination_timer: Timer = $NewDestinationTimer


func _ready() -> void:
	gun_holder.get_child(0).queue_free()
	gun_item = potential_gun_items[Globals.get_weighted_index(potential_gun_items)].object_to_spawn
	gun = gun_item.gun_object.instantiate()
	gun.gun_stats.condition = randf_range(10, 20)
	gun_holder.add_child(gun)
	shoot_timer.wait_time = gun.shoot_cooldown
	items_to_drop.append(gun_item.physical_item)
	var rng = RandomNumberGenerator.new()
	var ammo_amount = [0, 1, 2, 3]
	var weights = PackedFloat32Array([1.0, 0.5, 0.1, 0.05])
	for i in ammo_amount[rng.rand_weighted(weights)]:
		inventory.add_item(gun.ammo_item)
	DayNightCycle.night_start.connect(on_night_start)
	DayNightCycle.day_start.connect(on_day_start)
	time_to_see_max += randf_range(-0.25, 0.25)
	# state machine
	state_functions = {
		states.idle: state_idle,
		states.investigate: state_investigate,
		states.shoot: state_shoot,
		states.search: state_search,
		states.strafe: state_strafe,
		states.hurt: state_hurt,
		states.reload: state_reload,  
		states.camp: state_camp,  
		states.dead: state_dead,
		states.aim: state_aim,
		states.walk: state_walk,
		states.supress: state_supress,
		states.find_cover: state_find_cover,
		states.approach: state_approach,
	}
	# set affinity to player
	await get_tree().process_frame
	set_detection_targets()


func _physics_process(delta: float) -> void:
	target = detection.get_visible_target()
	if target:
		last_seen_position = target.global_position
	$Label3D.text = str(state)
	# state machine
	if state_functions.has(state):
		state_functions[state].call(delta)
	# Add gravity, push, and move
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity += push_velocity
	move_and_slide()
	#if velocity != Vector3.ZERO:
	velocity -= push_velocity
	push_velocity = Vector3.ZERO
	# push other npcs
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is CharacterBody3D:
			var _push_velocity = (collider.global_position - global_position).normalized() * walk_speed
			_push_velocity.y = 0
			collider.push_velocity = _push_velocity


func state_idle(delta) -> void:
	if is_new_state:
		velocity = Vector3.ZERO
		on_alert = false
		if goal == goals.travel and destination != Vector3.ZERO and global_position.distance_to(destination) > 1:
			change_state(states.walk)
			return
		is_new_state = false
	# switch to walk
	if goal == goals.follow and follow_target and global_position.distance_to(follow_target.global_position) > navigation_agent.target_desired_distance:
		change_state(states.walk)
		return
	# switch to investigate
	if target != null and open_fire:
		time_to_see += delta
		if time_to_see > time_to_see_max:
			time_to_see = 0
			change_state(states.investigate)
			return
	# animate
	anim_player.play("Idle")


func state_walk(delta) -> void:
	if is_new_state:
		if goal == goals.travel:
			navigation_agent.target_desired_distance = 1.0
			navigation_agent.set_target_position(destination)
		is_new_state = false
	# follow target
	if goal == goals.follow:
		#if global_position.distance_to(follow_target.global_position) > 3:
		navigation_agent.target_desired_distance = 5.0
		navigation_agent.set_target_position(follow_target.global_position)
	# follow path
	var spd = walk_speed
	if goal == goals.follow:
		if follow_target == Globals.player:
			spd = Globals.player.speed - 0.5
		else:
			spd = run_speed
	elif goal == goals.travel and follow_target == Globals.player:
		spd = run_speed
	follow_path(spd)
	#if navigation_agent.is_navigation_finished():
		#change_state(states.idle)
		#return
	
	# switch to investigate
	if target != null and open_fire:
		time_to_see += delta
		if time_to_see > time_to_see_max:
			time_to_see = 0
			change_state(states.investigate)
			return
	# switch to idle
	if goal == goals.guard:
		change_state(states.idle)
		return
	# animate
	if spd <= 2.5:
		anim_player.play("Walk")
	else:
		anim_player.play("Run")


func state_investigate(delta) -> void:
	if is_new_state:
		time_to_detect = time_to_detect_max
		if target == Globals.player:
			time_to_detect += 0.2 * PlayerStats.skills.stealth
		velocity = Vector3.ZERO
		is_new_state = false
	# detect target
	if target:
		look_at_position(target.global_position)
		var dis_to_target = global_position.distance_to(target.global_position)
		time_to_detect -= (20 / dis_to_target) * delta
		if time_to_detect <= 0 or on_alert:
			if randf() > 0.5:
				change_state(states.find_cover)
				return
			else:
				change_state(states.approach)
				return
	else:
		if return_to_idle_timer.time_left <= 0:
			return_to_idle_timer.start()
	# animate
	anim_player.play("IdlePoint")


func state_approach(_delta) -> void:
	if is_new_state:
		if target:
			if global_position.distance_to(target.global_position) > gun.engagement_range:
				navigation_agent.target_position = target.global_position
			else:
				change_state(states.aim)
				return
		is_new_state = false
	# leave approach
	if !target:
		#if goal == goals.follow:
			#change_state(states.idle)
		#else:
		change_state(states.search)
		return
	# approach and start shooting
	follow_path(run_speed)
	if navigation_agent.distance_to_target() <= gun.engagement_range:
		change_state(states.aim)
		return
	anim_player.play("Run")


func state_aim(_delta) -> void:
	if is_new_state:
		on_alert = true
		velocity = Vector3.ZERO
		aim_timer.start()
		anim_player.play("Aim")
		is_new_state = false
	if target:
		look_at_position(target.global_position)
	else:
		look_at_position(last_seen_position)


func state_shoot(delta) -> void:
	if is_new_state:
		if !target:
			on_alert = true
			if goal == goals.follow:
				change_state(states.idle)
			else:
				if randf() <= camp_chance:
					change_state(states.camp)
				#elif randf() <= supress_change:
					#change_state(states.supress)
				else:
					change_state(states.search)
			return
		anim_player.play("Fire")
		velocity = Vector3.ZERO
		is_new_state = false
	# look at target
	if target and gun:
		look_at_position(last_seen_position)
		if gun.fire_point != null:
			gun.fire_point.look_at(detection.target_pos)
	# switch to search
	if !target:
		time_since_detect += delta
		if time_since_detect >= 3:
			if randf() <= camp_chance:
				change_state(states.camp)
			#elif randf() <= supress_change:
				#change_state(states.supress)
			else:
				change_state(states.search)
			return
	else:
		time_since_detect = 0


func state_supress(_delta) -> void:
	if is_new_state:
		look_at_position(last_seen_position)
		anim_player.play("Fire")
		velocity = Vector3.ZERO
		supress_timer.start()
		is_new_state = false


func state_reload(_delta) -> void:
	if is_new_state:
		velocity = Vector3.ZERO
		anim_player.play("Reload")
		is_new_state = false


func state_camp(delta) -> void:
	if is_new_state:
		velocity = Vector3.ZERO
		time_since_detect = 0
		camp_time = randf_range(camp_time_min, camp_time_max)
		anim_player.play("IdlePoint")
		is_new_state = false
	if target:
		change_state(states.shoot)
		return
	time_since_detect += delta
	if time_since_detect > camp_time:
		if last_seen_position != Vector3.ZERO:
			#navigation_agent.set_target_position(last_seen_position)
			change_state(states.search)
		else:
			change_state(states.investigate)


func state_search(_delta) -> void:
	if is_new_state:
		if last_seen_position == Vector3.ZERO:
			change_state(states.investigate)
			return
		navigation_agent.target_desired_distance = 3.0
		navigation_agent.set_target_position(last_seen_position)
		is_new_state = false
	# go to last seen position
	follow_path(run_speed)
	# return to shoot
	if target:
		change_state(states.approach)
		return
	# animate
	anim_player.play("Run")


func state_strafe(_delta) -> void:
	# set new strafe position
	if is_new_state:
		var new_pos = global_position
		new_pos = global_position + Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
		navigation_agent.target_desired_distance = 0.5
		navigation_agent.set_target_position(new_pos)
		is_new_state = false
	# run to new position
	follow_path(run_speed)
	# stop strafing
	#if velocity.length() < 0.1:
		#look_at_position(last_seen_position)
		#change_state(states.approach)
		#return
	# animate
	if velocity == Vector3.ZERO:
		anim_player.play("Idle")
	else:
		anim_player.play("Run")


func state_find_cover(_delta) -> void:
	if is_new_state:
		var potential_cover = get_tree().get_nodes_in_group("cover")
		potential_cover = potential_cover.filter(func(a): 
			return global_position.distance_to(a.global_position) < 15)
		potential_cover = potential_cover.filter(func(a): 
			for _target in detection.targets:
				if _target == null: continue
				detection.global_position.x = a.global_position.x
				detection.global_position.z = a.global_position.z
				detection.force_shapecast_update()
				return !detection.can_see_target(_target))
		detection.position = Vector3(0, 1, 0)
		if potential_cover.size() == 0:
			change_state(states.strafe)
			return
		potential_cover.sort_custom(func(a, b): return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
		var cover_pos = potential_cover[0].global_position
		navigation_agent.target_desired_distance = 0.5
		navigation_agent.set_target_position(cover_pos)
		#if !navigation_agent.is_target_reachable():
			#change_state(states.approach)#states.strafe)
			#return
		is_new_state = false
	
	# run to new position
	follow_path(run_speed)
	
	# animate
	if velocity == Vector3.ZERO:
		anim_player.play("Idle")
	else:
		anim_player.play("Run")


func state_hurt(_delta) -> void:
	pass


func state_dead(_delta) -> void:
	pass


func change_state(new_state: states):
	#if state == new_state:
		#return
	if state == states.shoot:
		shoot_timer.stop()
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
	if !is_inside_tree():
		return
	var target_pos = pos
	target_pos.y = global_position.y
	if target_pos.distance_to(global_position) > 0.1:
		look_at(target_pos, Vector3.UP)


func set_detection_targets():
	detection.targets.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if FactionManager.get_faction_relation(faction, enemy.faction) <= -1.0:
			detection.targets.append(enemy)
	if Globals.player and FactionManager.get_faction_relation(faction, PlayerStats.faction) <= -1.0:
		detection.targets.append(Globals.player)


func target_player():
	detection.targets.append(Globals.player) 


func emit_shoot() -> void:
	if !gun:
		return
	gun.shoot(self)
	shoot_timer.start()
	Globals.noise_controller.create_noise_event(gun.fire_point.global_position, self, gun.bullet_stats.noise_radius)



func on_noise_heard(noise_position: Vector3, event_creator):
	if event_creator and FactionManager.get_faction_relation(faction, event_creator.faction) > -1.0:
		return
	if state == states.dead or state == states.hurt:
		return
	if target:
		return
	if !on_alert and open_fire:
		last_seen_position = noise_position
		#navigation_agent.set_target_position(noise_position)
		#target = event_creator
		change_state(states.investigate)
	elif state == states.investigate:
		time_to_detect -= 0.5
	on_alert = true
	look_at_position(noise_position)


func _on_damaged(hit_position: Vector3, hit_direction: Vector3, shooter: Node3D) -> void:
	velocity = Vector3.ZERO
	damage_position = hit_position
	damage_direction = hit_direction
	last_seen_position = shooter.global_position
	if faction != shooter.faction:
		var previous_relation = FactionManager.get_faction_relation(faction, shooter.faction)
		var show_notificaition = health_component.hp <= 0
		FactionManager.change_faction_relation(faction, shooter.faction, -1, show_notificaition)
		var current_relation = FactionManager.get_faction_relation(faction, shooter.faction)
		if current_relation < previous_relation:
			get_tree().call_group("enemies", "set_detection_targets")
	if !detection.priority_targets.has(shooter):
		detection.priority_targets.append(shooter)
	var blood_scene = load("res://Scenes/Effects/Particles/bloodspray.tscn")
	var blood = Globals.create_particle(blood_scene, hit_position)
	if blood != null:
		blood.set_deferred("rotation", Vector3(0, hit_direction.y, 0))
		blood.set_deferred("emitting", true)
	if state == states.dead:
		return
	anim_player.play("HitReaction")
	change_state(states.hurt)


func _on_death() -> void:
	#loot_area.process_mode = PROCESS_MODE_INHERIT
	ProgressManager.kills += 1
	for i in items_to_drop:
		var inst = i.instantiate()
		get_tree().current_scene.add_child.call_deferred(inst)
		inst.set_deferred("global_position", right_hand.global_position)
		inst.apply_impulse.call_deferred(Vector3(randf_range(-2, 2), 5, randf_range(-2, 2)))
		if i == gun_item.physical_item:
			inst.item_slot.item = gun_item
			inst.item_slot.item.gun_stats = gun.gun_stats.duplicate(true)
		#inst.apply_torque(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))
	if gun:
		gun.queue_free()
	velocity = Vector3.ZERO
	#anim_player.play("Die")
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	anim_player.active = false
	physical_bone_simulator.active = true
	physical_bone_simulator.physical_bones_start_simulation()
	var bones = physical_bone_simulator.get_children()
	bones.sort_custom(func(a, b): return a.global_position.distance_to(damage_position) < b.global_position.distance_to(damage_position))
	for i in bones.size():
		var bone = bones[i]
		bone.apply_impulse(-damage_direction * 5)
		if i > 3:
			continue
	if bounty:
		bounty.completed = true
		bounty.location = bounty.return_location
		Globals.survival_ui.create_notification("Bounty target killed")
	change_state(states.dead)
	shoot_timer.stop()
	aim_timer.stop()
	if has_node("Sprite3D"):
		$Sprite3D.hide()


func _on_navigation_agent_3d_navigation_finished() -> void:
	if state == states.idle:
		path_wait_timer.start()
		velocity = Vector3.ZERO
	elif state == states.search:
		change_state(states.investigate)
	elif state == states.strafe:
		change_state(states.aim)
	elif state == states.walk:
		if goal == goals.travel:
			change_state(states.idle)
			destination = Vector3.ZERO
			if !follow_target:
				new_destination_timer.start()
		elif goal == goals.follow:
			change_state(states.idle)
	elif state == states.find_cover:
		look_at(last_seen_position)
		change_state(states.camp)


func _on_return_to_idle_timer_timeout() -> void:
	if state == states.investigate and !detection.get_visible_target():
		#if on_alert:
			#change_state(states.search)
		#else:
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
		look_at_position(last_seen_position)
		if randf() > 0.5:
			change_state(states.approach)
		else:
			change_state(states.find_cover)
	#elif anim_name == "Fire":
		##emit_shoot()
		#gun.gun_stats.ammo -= 1
		#if gun.gun_stats.ammo <= 0:
			#gun.gun_stats.ammo = gun.max_ammo
			#change_state(states.reload)
			#return
		#if state == states.shoot and randf_range(0, 1) <= strafe_change:
			##change_state(states.strafe)
			#change_state(states.find_cover)
		#else:
			#shoot_timer.start()
			#await shoot_timer.timeout
			#anim_player.play("Fire")
	elif anim_name == "Reload":
		if target:
			look_at_position(target.global_position)
		change_state(states.shoot)


func _on_shoot_timer_timeout() -> void:
	gun.gun_stats.ammo -= 1
	if gun.gun_stats.ammo <= 0:
		gun.gun_stats.ammo = gun.max_ammo
		change_state(states.reload)
		return
	if state == states.shoot and randf_range(0, 1) <= strafe_change:
		change_state(states.find_cover)
	else:
		anim_player.play("Fire")
		anim_player.seek(0.0)

func _on_aim_timer_timeout() -> void:
	change_state(states.shoot)


func on_night_start() -> void:
	detection.detection_range = night_range


func on_day_start() -> void:
	detection.detection_range = day_range


func _on_supress_timer_timeout() -> void:
	if randf() < 0.5:
		change_state(states.search)
	else:
		change_state(states.camp)


func _on_new_destination_timer_timeout() -> void:
	if state != states.idle:
		return
	destination = get_tree().current_scene.get_node("EnemySpawner").get_destination(global_position)
	change_state(states.walk)
