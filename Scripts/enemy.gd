extends CharacterBody3D
class_name Enemy

@export var title: String = "Enemy"
@export var strafe_change := 0.5
@export var items_to_drop: Array[PackedScene]
#enum guns {shotgun, ak47, sniper, pistol}
#@export var gun_index: guns
@export var potential_gun_items: Array[SpawnChanceResource]
var gun_item: EquipmentGun
enum teams {enemies, allies}
@export var team: teams = teams.enemies
@export var follow_target: Node3D
@export var potential_items: Array[SpawnChanceResource]
var items:
	get():
		return inventory.items
@export var inventory: Inventory
@export var max_items: int
@export var min_items: int
enum states {idle, investigate, shoot, search, strafe, hurt, reload, camp, dead, aim, walk, standby, supress}
var state = states.idle
var walk_speed := 1.5
var run_speed := 3.0
var time_to_detect_max := 1.5
var camp_chance := 0.1
var supress_change := 0.25
var camp_time := 5
var camp_time_min := 5
var camp_time_max := 10
var time_to_detect: float = time_to_detect_max
var time_since_bleed: float
var time_since_detect: float
var time_to_see_max: float = 1.0
var time_to_see: float = 0.0
var day_range := 100
var night_range := 25
var path_index: int
var is_new_state: bool
var on_alert: bool
var free_on_destination: bool
var is_starting_squad: bool
var gun: Node3D
var damage_position: Vector3
var damage_direction: Vector3
var last_seen_position: Vector3
var destination: Vector3
var target: Node3D
var bounty: Quest
#var guns_dict: Dictionary = {
	#0 : [preload("res://Scenes/Guns/shotgun.tscn"), preload("res://Resources/Items/Guns/shotgun.tres")],
	#1 : [preload("res://Scenes/Guns/ak47.tscn"), preload("res://Resources/Items/Guns/ak47.tres")],
	#2 : [preload("res://Scenes/Guns/sniper.tscn"), preload("res://Resources/Items/Guns/sniper_rifle.tres")],
	#3 : [preload("res://Scenes/Guns/pistol.tscn"), preload("res://Resources/Items/Guns/pistol.tres")],
#}
@onready var detection = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var return_to_idle_timer: Timer = $ReturnToIdleTimer
@onready var path_wait_timer: Timer = $PathWaitTimer
@onready var right_hand: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var shoot_component: Node = $ShootComponent
@onready var gun_holder: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var shoot_timer: Timer = $ShootTimer
@onready var loot_area: Area3D = $Loot
@onready var health_component: HealthComponent = $Hitbox
@onready var aim_timer: Timer = $AimTimer
@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var supress_timer: Timer = $SupressTimer
@onready var new_destination_timer: Timer = $NewDestinationTimer
signal shoot


func _ready() -> void:
	gun_holder.get_child(0).queue_free()
	#gun = guns_dict[gun_index][0].instantiate()
	gun_item = potential_gun_items[Globals.get_weighted_index(potential_gun_items)].object_to_spawn
	gun = gun_item.gun_object.instantiate()
	gun.gun_stats.condition = randf_range(10, 50)
	gun_holder.add_child(gun)
	gun.bullet_stats.collision_mask = 4
	shoot_component.firepoint = gun.fire_point
	shoot_component.tracer_firepoint = gun.fire_point
	shoot_component.bullet_stats = gun.bullet_stats
	shoot_component.gun_stats = gun.gun_stats
	shoot_timer.wait_time = gun.shoot_cooldown
	items_to_drop.append(gun_item.physical_item)
	shoot.connect($ShootComponent._on_shoot)
	shoot.connect(gun._on_shoot)
	DayNightCycle.night_start.connect(on_night_start)
	DayNightCycle.day_start.connect(on_day_start)
	
	# add items
	for i in randi_range(min_items, max_items):
		inventory.add_item(potential_items[Globals.get_weighted_index(potential_items)].object_to_spawn)
	
	await get_tree().create_timer(0.5).timeout
	if team == teams.allies:
		detection.targets = get_tree().get_nodes_in_group("enemies")
		shoot_component.bullet_stats.collision_mask = 3
	elif team == teams.enemies:
		detection.targets = get_tree().get_nodes_in_group("allies")
		shoot_component.bullet_stats.collision_mask = 4
	


func _physics_process(delta: float) -> void:
	if state == states.standby:
		if is_new_state:
			visible = false
			position = Vector3.ONE * 1000
			is_new_state = false
		return
	$Label3D.text = str(state)
	match state:
		states.idle:
			if is_new_state:
				on_alert = false
				velocity = Vector3.ZERO
				if destination != Vector3.ZERO:
					change_state(states.walk)
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
			
			# return to walk
			if destination != Vector3.ZERO:
				change_state(states.walk)
			
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
			
		states.walk:
			if is_new_state:
				navigation_agent.set_target_position(destination)
				anim_player.play("Walk")
			
			follow_path()
			
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
					change_state(states.aim)
			else:
				if return_to_idle_timer.time_left <= 0:
					return_to_idle_timer.start()
			anim_player.play("IdlePoint")
		
		states.aim:
			if is_new_state:
				on_alert = true
				velocity = Vector3.ZERO
				aim_timer.start()
				anim_player.play("Aim")
				#for enemy in get_tree().get_nodes_in_group("enemies"):
					#if enemy.state == states.idle or enemy.state == states.walk:
						#enemy.change_state(states.investigate)
				is_new_state = false
			
			if target:
				look_at_position(target.global_position)
		
		states.shoot:
			if is_new_state:
				on_alert = true
				anim_player.play("Fire")
				if !target:
					if randf() <= camp_chance:
						change_state(states.camp)
					elif randf() <= supress_change:
						change_state(states.supress)
					else:
						#navigation_agent.set_target_position(last_seen_position)
						change_state(states.search)
					return
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
				if shoot_component.firepoint != null:
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
					elif randf() <= supress_change:
						change_state(states.supress)
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
		
		states.supress:
			if is_new_state:
				look_at_position(last_seen_position)
				anim_player.play("Fire")
				velocity = Vector3.ZERO
				supress_timer.start()
				is_new_state = false
			
		
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
				change_state(states.aim)
			
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
			
			# return to shoot
			if target:
				change_state(states.aim)
			
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
				change_state(states.aim)
			
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
		if PlayerStats.state == PlayerStats.states.dead:
			target = null
		else:
			target = detection.get_visible_target()



func _process(delta: float) -> void:
	time_since_bleed += delta


func change_state(new_state: states):
	if state == new_state:
		return
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
	if team == teams.allies:
		detection.targets = get_tree().get_nodes_in_group("enemies").filter(func(i): return i.state != states.dead)
	elif team == teams.enemies:
		detection.targets = get_tree().get_nodes_in_group("allies").filter(func(i): return i.state != states.dead)


func emit_shoot() -> void:
	if gun:
		shoot.emit()
		shoot_timer.start()


func on_noise_heard(noise_position: Vector3, event_creator):
	pass
	if event_creator and event_creator.is_in_group(get_groups()[0]):
		return
	if state == states.dead or state == states.hurt:
		return
	if target:
		return
	if !on_alert:
		last_seen_position = noise_position
		#navigation_agent.set_target_position(noise_position)
		#target = event_creator
		change_state(states.investigate)
	elif state == states.investigate:
		time_to_detect -= 0.5
	on_alert = true
	look_at_position(noise_position)


func _on_damaged(hit_position: Vector3, hit_direction: Vector3) -> void:
	velocity = Vector3.ZERO
	damage_position = hit_position
	damage_direction = hit_direction
	#if time_since_bleed < 0.1:
		#return
	#time_since_bleed = 0
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
	#loot_area.process_mode = PROCESS_MODE_INHERIT
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
	anim_player.active = false
	physical_bone_simulator.active = true
	physical_bone_simulator.physical_bones_start_simulation()
	var bones = physical_bone_simulator.get_children()
	bones.sort_custom(func(a, b): return a.global_position.distance_to(damage_position) < b.global_position.distance_to(damage_position))
	#var head = physical_bone_simulator.get_node("Physical Bone mixamorig_Head")
	bones[0].apply_impulse(damage_direction.normalized() * 35)
	if bounty:
		bounty.completed = true
		bounty.location = bounty.return_location
	change_state(states.dead)
	shoot_timer.stop()
	aim_timer.stop()
	if team == teams.allies:
		get_tree().call_group("enemies", "set_detection_targets")
	if team == teams.enemies:
		get_tree().call_group("allies", "set_detection_targets")
	if has_node("Sprite3D"):
		$Sprite3D.hide()


func _on_navigation_agent_3d_navigation_finished() -> void:
	if free_on_destination:
		queue_free()
	if state == states.idle:
		path_wait_timer.start()
		velocity = Vector3.ZERO
	elif state == states.search:
		change_state(states.investigate)
	elif state == states.strafe:
		look_at_position(last_seen_position)
		change_state(states.aim)
	elif state == states.walk:
		change_state(states.idle)
		new_destination_timer.start()


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
		change_state(states.aim)
	elif anim_name == "Fire":
		#emit_shoot()
		gun.gun_stats.ammo -= 1
		if gun.gun_stats.ammo <= 0:
			gun.gun_stats.ammo = gun.max_ammo
			change_state(states.reload)
			return
		if state == states.shoot and randf_range(0, 1) <= strafe_change:
			change_state(states.strafe)
		else:
			shoot_timer.start()
			await shoot_timer.timeout
			anim_player.play("Fire")
	elif anim_name == "Reload":
		if target:
			look_at_position(target.global_position)
		change_state(states.aim)


func _on_shoot_timer_timeout() -> void:
	pass
	#if anim_player.current_animation == "Fire":
		#anim_player.advance(anim_player.current_animation.length())


func _on_aim_timer_timeout() -> void:
	change_state(states.shoot)


func on_night_start() -> void:
	detection.range = night_range


func on_day_start() -> void:
	detection.range = day_range


func _on_supress_timer_timeout() -> void:
	if randf() < 0.5:
		change_state(states.search)
	else:
		change_state(states.camp)


func _on_new_destination_timer_timeout() -> void:
	if state != states.idle:
		return
	destination = get_tree().current_scene.get_node("enemy_spawner").get_destination(global_position)
	change_state(states.walk)
