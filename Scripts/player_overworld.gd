extends CharacterBody3D

enum camera_types {overhead, town}
var camera_type = camera_types.overhead
var speed := 4.5:
	get():
		return speed + PlayerStats.skills.speed * 0.2
var mouse_sensitivity := 0.004
var camera_max_zoom: float = 20.0
var camera_min_zoom: float = 2.0
var camera_target_zoom: float = 10.0
var camera_zoom_incrament: float = 1
var model_rotation: float:
	set(value):
		if model:
			model.rotation.y = value
	get():
		if model:
			return model.rotation.y
		else:
			return 0.0
var can_enter_location: bool = false
var is_moving_camera: bool
var run_animation := "Run"
var idle_animation := "Idle"
var state_functions: Dictionary
var exit_functions: Dictionary
var enter_functions: Dictionary
var faction := FactionManager.factions.player 
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var model: Node3D = $EnemyModel
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var camera: Camera3D = %OverheadCamera
@onready var gun_anchor: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var ak_47: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/ak_47
@onready var pistol: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/Pistol
@onready var sniper_rifle: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/SniperRifle
@onready var shotgun: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/Shotgun
@onready var sawed_off: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/SawedOff
@onready var uzi: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/Uzi
@onready var hunting_rifle: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/HuntingRifle
@onready var hitbox: HealthComponent = $HealthComponent
@onready var spot_light: SpotLight3D = $EnemyModel/SpotLight3D
@onready var skeleton: Skeleton3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D
@onready var physical_bone_simulator_3d: PhysicalBoneSimulator3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var loot_area: Area3D = $EnemyModel/LootArea
@onready var notification_position: Node3D = $NotificationPosition
@onready var hud_anchor: Node3D = $HudAnchor
@onready var town_shot: Node3D = %TownShot
@onready var transition_shot: Node3D = $CameraAnchor/RotationOffset/TransitionShot
@onready var overhead_shot: Node3D = %OverheadShot
@onready var spring_arm: SpringArm3D = $CameraAnchor/RotationOffset/SpringArm3D
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var move_marker: Node3D = $MoveMarker
var gun: Node3D


func _enter_tree() -> void:
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	global_position.y = Globals.get_heightmap_position(global_position)
	camera_type = camera_types.overhead
	if PlayerStats.faction:
		faction = PlayerStats.faction
	await get_tree().process_frame
	hitbox.hp = PlayerStats.hp
	if PlayerStats.gun:
		change_gun(PlayerStats.gun)
	else:
		unequip_gun()
	can_enter_location = false
	await get_tree().create_timer(1.0).timeout
	can_enter_location = true


func _ready() -> void:
	PlayerStats.gun_changed.connect(_on_gun_changed)
	hitbox.hp_bar = Globals.survival_ui.player_hp_bar
	state_functions = {
		PlayerStats.states.walk: state_walk,
		PlayerStats.states.pause: state_pause,
		PlayerStats.states.dead: state_dead,
	}


func _process(_delta: float) -> void:
	if navigation_agent.target_position != Vector3.ZERO and !navigation_agent.is_target_reached():
		move_marker.visible = true
		move_marker.global_position = navigation_agent.target_position
	else:
		move_marker.visible = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# zoom camera
	if PlayerStats.state != PlayerStats.states.pause:
		if Input.is_action_just_pressed("next_gun"):
			camera_target_zoom = clamp(camera_target_zoom - camera_zoom_incrament, camera_min_zoom, camera_max_zoom)
		elif Input.is_action_just_pressed("last_gun"):
			camera_target_zoom = clamp(camera_target_zoom + camera_zoom_incrament, camera_min_zoom, camera_max_zoom)
	spring_arm.spring_length = lerp(spring_arm.spring_length, camera_target_zoom, delta * 5)
	
	# turn camerea
	if Input.is_action_pressed("lean_left"):
		camera_anchor.rotate_y(2 * delta)
	elif Input.is_action_pressed("lean_right"):
		camera_anchor.rotate_y(-2 * delta)
	
	#overhead_shot.rotation = Vector3.ZERO
	var camera_target: Node3D = overhead_shot
	model.show()
	if camera_type == camera_types.town:
		var rot = town_shot.rotation
		town_shot.look_at(Globals.overworld.current_encounter.global_position)
		town_shot.rotation = Vector3(rot.x, town_shot.rotation.y, rot.z)
		camera_target = town_shot
		model.hide()
	camera.global_position = lerp(camera.global_position, camera_target.global_position, delta * 10)
	camera.global_rotation.x = lerp_angle(camera.global_rotation.x, camera_target.global_rotation.x, delta * 10)
	camera.global_rotation.y = lerp_angle(camera.global_rotation.y, camera_target.global_rotation.y, delta * 10)
	camera.global_rotation.z = lerp_angle(camera.global_rotation.z, camera_target.global_rotation.z, delta * 10)
	
	# clamp position
	position.x = clamp(position.x, 1, 511)
	position.z = clamp(position.z, 1, 511)
	
	# make sure you don't fall under the world
	if global_position.y < 0:
		var terrain_y = Globals.get_heightmap_position(global_position)
		if global_position.y < terrain_y:
			global_position.y = terrain_y


func state_walk(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# set camera
	camera_type = camera_types.overhead
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := ((camera_anchor.transform.basis * transform.basis) * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		navigation_agent.set_target_position(Vector3.ZERO)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if navigation_agent.target_position != Vector3.ZERO:
		follow_path()
		var vel_norm = velocity.normalized()
		direction.x = vel_norm.x
		direction.z = vel_norm.z
	
	move_and_slide()
	
	# animate
	if direction != Vector3.ZERO:
		animation_player.play(run_animation)
	else:
		animation_player.play(idle_animation)
	if direction != Vector3.ZERO:
		model.look_at(global_position + direction)
	
	# change gun
	#var kit = PlayerStats.inventory.equipment_kit.gun_slots
	#if Input.is_action_just_released("next_gun"):
		#change_gun_slot(wrap(PlayerStats.gun_index - 1, 0, kit.size()))
	#elif Input.is_action_just_released("last_gun"):
		#change_gun_slot(wrap(PlayerStats.gun_index + 1, 0, kit.size()))
	#elif Input.is_action_just_pressed("slot_1"):
		#change_gun_slot(0)
	#elif Input.is_action_just_pressed("slot_2"):
		#change_gun_slot(1)
	
	# light
	var tool = PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.tool]
	spot_light.visible = tool != null and tool.title == "Flashlight"
	#var flashlight = PlayerStats.inventory.find_item("flashlight")
	#if Input.is_action_just_pressed("light") and flashlight and flashlight.equipped:
		#PlayerStats.flashlight_on = !PlayerStats.flashlight_on
	#if PlayerStats.flashlight_on:
		#spot_light.visible = true
	#else:
		#spot_light.visible = false
	
	# pick up loot
	if Input.is_action_just_pressed("interact"):
		var areas = loot_area.get_overlapping_areas()
		if areas.size() > 0:
			Globals.survival_ui.loot(areas[0])
			return
		var bodies = loot_area.get_overlapping_bodies()
		if bodies.size() > 0:
			Globals.survival_ui.loot(bodies[0])
	
	# set gun sprite
	#if gun != PlayerStats.gun:
		#change_gun(PlayerStats.gun)


func state_pause(_delta) -> void:
	animation_player.play(idle_animation)


func state_dead(_delta) -> void:
	pass


func follow_path():
	if navigation_agent.is_navigation_finished():
		return
	if !navigation_agent.is_target_reachable():
		navigation_agent.set_target_position(Vector3.ZERO)
		Globals.survival_ui.create_notification("Not reachable")
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var path_velocity = global_position.direction_to(next_path_position) * speed
	velocity = Vector3(path_velocity.x, path_velocity.y, path_velocity.z)


func change_gun(new_gun: Equipment) -> void:
	PlayerStats.gun = new_gun
	gun = get(PlayerStats.gun.resource_name)
	for i in gun_anchor.get_children():
		if i != gun:
			i.visible = false
		else:
			i.visible = true
	run_animation = "Run"
	idle_animation = "Idle"


func change_gun_slot(slot_index: int) -> void:
	var kit = PlayerStats.inventory.equipment_kit
	var _gun = kit.equipment[kit.gun_slots[slot_index]]
	if _gun != null:
		change_gun(_gun)
		PlayerStats.gun_index = slot_index


func unequip_gun() -> void:
	if gun:
		gun.visible = false
	PlayerStats.gun = null
	run_animation = "RunNoGun"
	idle_animation = "IdleNoGun"


func _input(event):
	if PlayerStats.state != PlayerStats.states.walk:
		return
	if event is InputEventMouseMotion and Input.is_action_pressed("shoot"):
		match camera_type:
			camera_types.overhead:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity * PlayerStats.sensitivity_modifier)
				is_moving_camera = true
	elif Input.is_action_just_released("shoot") and !Globals.survival_ui.menu_buttons_has_mouse:
		if !is_moving_camera:
			var space_state = get_world_3d().direct_space_state
			var cam = get_viewport().get_camera_3d()
			var mousepos = get_viewport().get_mouse_position()
			var origin = cam.project_ray_origin(mousepos)
			var end = origin + camera.project_ray_normal(mousepos) * 1000.0
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			var result = space_state.intersect_ray(query)
			if result:
				navigation_agent.set_target_position(result.position)
		else:
			await get_tree().create_timer(0.1).timeout
			is_moving_camera = false


func save() -> Dictionary:
	return {
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"model_rotation": model_rotation,
	}


func _on_gun_changed() -> void:
	if PlayerStats.gun:
		if PlayerStats.gun == PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.primary_gun]:
			gun = get(PlayerStats.gun.resource_name)
			change_gun(PlayerStats.gun)
		elif !PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.primary_gun]:
			gun = get(PlayerStats.gun.resource_name)
			change_gun(PlayerStats.gun)
	else:
		unequip_gun()


func _on_damaged(_hit_position: Vector3, _hit_direction: Vector3, _shooter: Node3D) -> void:
	pass


func _on_death() -> void:
	PlayerStats.change_state(PlayerStats.states.dead)
	animation_player.play("Die")
	await animation_player.animation_finished
	UiController.open_interface(Globals.survival_ui.progress_menu, false)
