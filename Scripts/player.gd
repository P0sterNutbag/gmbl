extends CharacterBody3D
class_name Player

enum zoom_levels {regular, ads, zoom}
enum gun_states {point, ads, reload, ammo_check, no_gun, point_up, pump, unjam}
var camera_zoom = zoom_levels.regular
var gun_state = gun_states.point
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var base_speed := 4.5:
	get():
		return base_speed + PlayerStats.skills.speed * 0.3
var walk_speed := 2.5:
	get():
		return walk_speed + PlayerStats.skills.speed * 0.3
var run_speed := 7.0:
	get():
		return run_speed + PlayerStats.skills.speed * 0.3
var crouch_speed := 2.5:
	get():
		return crouch_speed + (PlayerStats.skills.speed * 0.3) + (PlayerStats.skills.stealth * 0.2)
var speed = base_speed
var jump_speed := 6.5
var mouse_sensitivity := 0.004
var controller_sensitivity := 0.04
var lean_angle := 20.0
var lean_interp := 0.0
var gun_index := -1
var crouch_height := 0.50
var base_fov := 75.0
var walk_time := 0.0
var push_force := 20
var sway_time := 0.0
var sway_speed = 0.1
var sway_speed_hold_breath = 0.01
var footstep_timer := 0.0
var sway_intensity = 3
var max_breath = 2.0:
	get():
		return max_breath + ((PlayerStats.skills.guns) * 0.3)
var current_breath = 3.0
var is_crouching: bool
var is_sprinting: bool
var is_walking: bool
var on_ladder: bool
var can_hold_breath: bool = true
var is_holding_breath: bool
var aim_rotation: Vector3
var ally_destination: Vector3
var ammo: int:
	get():
		if gun and "gun_stats" in gun:
			return gun.gun_stats.ammo
		return 0
var gun: Node3D
var object_to_place: Node3D
var gun_tween: Tween
var unequip_tween: Tween
var walk_tween: Tween
var sway_noise := FastNoiseLite.new()
var state_functions: Dictionary
var exit_functions: Dictionary
var enter_functions: Dictionary
var gun_state_functions: Dictionary
var gun_exit_functions: Dictionary
var gun_enter_functions: Dictionary
var faction = FactionManager.factions.player
var grenade_object = preload("res://Scenes/Bullets/grenade.tscn")
const FPS_ARM = preload("uid://b1xdclr1651mj")
const PLAYER_STYLE = preload("uid://b4ypcwfcexyed")
@onready var camera = $CameraAnchor/Camera3D
@onready var gun_pivot: Node3D = %GunPivot
@onready var gun_offset: Node3D = %GunPivot/GunOffset
@onready var gun_anchor: Node3D = %GunPivot/GunOffset/GunAnchor
@onready var ads_position: Node3D = $CameraAnchor/Camera3D/AdsOffset/AdsPosition
@onready var pistol: Node3D = %GunPivot/GunOffset/GunAnchor/Pistol
@onready var ak_47: Node3D = %GunPivot/GunOffset/GunAnchor/AK47
@onready var sniper_rifle: Node3D = %GunPivot/GunOffset/GunAnchor/SniperRifle
@onready var shotgun: Node3D = %GunPivot/GunOffset/GunAnchor/Shotgun
@onready var sawed_off: Gun = %GunPivot/GunOffset/GunAnchor/SawedOff
@onready var uzi: Gun = %GunPivot/GunOffset/GunAnchor/Uzi
@onready var hunting_rifle: Gun = %GunPivot/GunOffset/GunAnchor/HuntingRifle
@onready var knife: Node3D = %GunPivot/GunOffset/GunAnchor/Knife
@onready var grenade: Node3D = %GunPivot/GunOffset/GunAnchor/Grenade
@onready var step_timer: Timer = $StepTimer
@onready var interact_cast: = $CameraAnchor/Camera3D/ShapeCast3D
@onready var hitbox: HealthComponent = $Hitbox
@onready var health_component: HealthComponent = $Hitbox
@onready var grenade_spawn: Node3D = $CameraAnchor/Camera3D/GrenadeSpawn
@onready var ally_raycast: RayCast3D =$CameraAnchor/Camera3D/AllyRaycast
@onready var bullet_flyby_sfx: AudioStreamPlayer3D = $CameraAnchor/BulletListener/AudioStreamPlayer3D
@onready var footstep_sfx: AudioStreamPlayer3D = $FootstepPlayer
@onready var spot_light: SpotLight3D = $CameraAnchor/Camera3D/SpotLight3D
@onready var gun_collision_cast: RayCast3D = %GunPivot/GunOffset/RayCast3D
@onready var move_marker: Node3D = $MoveMarker
@onready var hitbox_shape: CollisionShape3D = $Hitbox/CollisionShape3D
@onready var player_radgoll: Node3D = $PlayerRadgoll


func _enter_tree() -> void:
	PlayerStats.state = PlayerStats.states.walk
	aim_rotation = rotation


func _ready() -> void:
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if PlayerStats.faction:
		faction = PlayerStats.faction
	for i in gun_anchor.get_children():
		i.visible = false
	hitbox.hp_bar = Globals.survival_ui.player_hp_bar
	hitbox.hp = PlayerStats.hp
	sway_noise.seed = randi()
	sway_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	sway_noise.frequency = 0.5
	# state machine functions
	state_functions = {
		PlayerStats.states.walk: state_walk,
		PlayerStats.states.pause: state_pause,
		PlayerStats.states.dead: state_dead,
	}
	enter_functions = {
		PlayerStats.states.pause: enter_pause,
		PlayerStats.states.dead: enter_dead,
	}
	exit_functions = {
		PlayerStats.states.dead: exit_dead
	}
	gun_state_functions = {
		gun_states.ads: gun_state_ads,
		gun_states.no_gun: gun_state_no_gun,
		gun_states.point_up: gun_state_point_up,
	}
	gun_enter_functions = {
		gun_states.point: enter_gun_state_point,
		gun_states.ads: enter_gun_state_ads,
		gun_states.ammo_check: enter_gun_state_ammo_check,
		gun_states.no_gun: enter_gun_state_no_gun,
		gun_states.reload: enter_gun_state_reload,
		gun_states.point_up: enter_gun_state_point_up,
		gun_states.unjam: enter_gun_state_unjam,
	}
	gun_exit_functions = {
		gun_states.reload: exit_gun_state_reload,
		gun_states.ammo_check: exit_gun_state_ammo_check,
		gun_states.no_gun: exit_gun_state_no_gun,
		gun_states.point_up: exit_gun_state_point_up,
		gun_states.ads: exit_gun_state_ads,
	}
	# set gun
	PlayerStats.gun_index = -1
	gun_state = gun_states.no_gun
	if PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.primary_gun]:
		change_gun_slot(0)
	elif PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.secondary_gun]:
		change_gun_slot(1)
	else:
		change_gun_state(gun_states.no_gun)
	# set skin color
	var style = PLAYER_STYLE
	if PlayerStats.player_style:
		style = PlayerStats.player_style
	var new_color = style.skin_colors[0]
	new_color.v -= 0.14
	FPS_ARM.set("shader_parameter/color", new_color)
	# signals
	PlayerStats.gun_changed.connect(_on_gun_changed)


func _physics_process(delta):
	# apply gravity
	velocity.y += -gravity * delta
	# stay in boundaries
	position.x = clamp(position.x, 2, 255)
	position.z = clamp(position.z, 2, 255)
	# make sure you don't fall under the world
	if global_position.y < 0:
		var terrain_y = Globals.get_heightmap_position(global_position)
		if global_position.y < terrain_y:
			global_position.y = terrain_y


func _process(delta: float) -> void:
	# control camera
	if PlayerStats.state == PlayerStats.states.walk:
		rotation.y = aim_rotation.y
		camera.rotation.x = aim_rotation.x
	# state machine
	if gun_state_functions.has(gun_state):
		gun_state_functions[gun_state].call(delta)
	# ally commands
	for ally in PlayerStats.ally_npcs:
		ally.open_fire = PlayerStats.allies_shoot
		#if PlayerStats.allies_follow:
			#ally.goal = ally.goals.follow
		#else:
			#ally.goal = ally.goals.guard
	if ally_destination != Vector3.ZERO and PlayerStats.allies.size() > 0:
		var allies = PlayerStats.ally_npcs.filter(func(i): return i.state != i.states.idle)
		if allies.size() == 0:
			move_marker.hide()
		else:
			move_marker.show()
			move_marker.global_position = ally_destination
	else:
		move_marker.hide()


func change_gun_state(new_state):
	if new_state == gun_state:
		return
	if gun_exit_functions.has(gun_state):
		await gun_exit_functions[gun_state].call()
	gun_state = new_state
	if gun_enter_functions.has(gun_state):
		await gun_enter_functions[gun_state].call()


func _input(event):
	if PlayerStats.state != PlayerStats.states.walk:
		return
	if event is InputEventMouseMotion:
		aim_rotation.y += -event.relative.x * mouse_sensitivity * PlayerStats.sensitivity_modifier
		aim_rotation.x += -event.relative.y * mouse_sensitivity * PlayerStats.sensitivity_modifier
		aim_rotation.x = clampf(aim_rotation.x, -deg_to_rad(80), deg_to_rad(90))


func state_walk(delta):
	# get and apply inputs
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	#movement_dir = movement_dir.rotated(Vector3.UP, camera.rotation.y)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed
	
	# set speed
	if is_crouching:
		speed = crouch_speed
	else:
		if gun_state == gun_states.ads:
			speed = walk_speed
		elif is_sprinting: #Input.is_action_pressed("sprint") and input.y < 0 and (!gun or (gun.shoot_cooldown_timer.time_left == 0 and !Input.is_action_pressed("shoot"))):
			speed = run_speed
		elif is_walking:
			speed = walk_speed
		else:
			speed = base_speed
	
	# sprint
	if !is_sprinting:
		if Input.is_action_just_pressed("sprint"):
			is_sprinting = true
	else:
		if Input.is_action_just_pressed("sprint") or input.y >= 0:# or (gun and gun.shoot_cooldown_timer.time_left == 0 and Input.is_action_pressed("shoot")):
			is_sprinting = false
	
	# walking
	if Input.is_action_just_pressed("walk"):
		is_walking = !is_walking
	
	# jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed
	
	# ladder
	if on_ladder:
		if input.y != 0:
			velocity.y = -input.y * speed
			if !is_on_floor():
				velocity.x = 0
				velocity.z = 0
		else:
			velocity.y = 0
		if Input.is_action_just_pressed("jump"):
			transform = transform.translated(Vector3.FORWARD * 0.05)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force * delta)
	
	# controller camera movement
	var controller_vector = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down", 0.25)
	aim_rotation.y += -controller_vector.x * controller_sensitivity
	aim_rotation.x += -controller_vector.y * controller_sensitivity
	
	# change gun
	var kit = PlayerStats.inventory.equipment_kit
	if !Globals.ui.tooltip.visible:
		if Input.is_action_just_released("next_gun"):
			change_gun_slot(wrap(PlayerStats.gun_index - 1, 0, kit.gun_slots.size()))
		elif Input.is_action_just_released("last_gun"):
			change_gun_slot(wrap(PlayerStats.gun_index + 1, 0, kit.gun_slots.size()))
	if Input.is_action_just_pressed("slot_1") and !Input.is_action_pressed("command_allies"):
		change_gun_slot(0)
	elif Input.is_action_just_pressed("slot_2") and !Input.is_action_pressed("command_allies"):
		change_gun_slot(1)
	
	# leaning
	var target_interp = sign(Input.get_axis("lean_right", "lean_left"))
	lean_interp = lerp(lean_interp, target_interp, 10 * delta)
	rotation_degrees.x = lerp(0.0, Vector3(0.0, 0.0, lean_angle).rotated(Vector3.UP, camera.rotation.y).x, lean_interp)
	rotation_degrees.z = lerp(0.0, Vector3(0.0, 0.0, lean_angle).rotated(Vector3.UP, camera.rotation.y).z, lean_interp)
	
	# crouching
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		is_crouching = !is_crouching
	var cam_target_pos = Vector3.ZERO
	if is_crouching:
		cam_target_pos = Vector3.DOWN * crouch_height
	camera.position = lerp(camera.position, cam_target_pos, 10 * delta)
	hitbox_shape.position = lerp(camera.position, cam_target_pos, 10 * delta)
	
	# noise
	if abs(velocity) > Vector3.ZERO and is_on_floor() and !is_crouching:
		if step_timer.time_left <= 0:
			step_noise_event()
			step_timer.start()
	
	# gun direction/movement
	var target_rot: Vector3
	if gun_state == gun_states.point:
		var mouse_velocity = Input.get_last_mouse_velocity()
		if mouse_velocity.x != 0:
			target_rot.z = deg_to_rad(-sign(mouse_velocity.x) * 2.5)
		target_rot = Vector3(deg_to_rad(mouse_velocity.y * 0.001), deg_to_rad(mouse_velocity.x * 0.001), target_rot.z)
	else:
		target_rot = Vector3.ZERO
		target_rot.z = deg_to_rad(-sign(input.x) * 2.5)
	gun_pivot.rotation.x = lerp_angle(gun_pivot.rotation.x, target_rot.x, 10 * delta)
	gun_pivot.rotation.y = lerp_angle(gun_pivot.rotation.y, target_rot.y, 10 * delta)
	gun_pivot.rotation.z = lerp_angle(gun_pivot.rotation.z, target_rot.z, 5 * delta)
	
	# shooting and aiming
	if (gun_state == gun_states.ads or gun_state == gun_states.point) and gun.rotation.y == 0:
		if Input.is_action_pressed("shoot"):
			var did_use = gun.use(self)
			if !did_use:
				return
			if gun is Gun:
				var tween = create_tween().set_ease(Tween.EASE_OUT)
				tween.tween_property(gun, "position", Vector3(0, 0, 0.1), 0.01)
				tween.tween_property(gun, "position", Vector3.ZERO, 0.2)
				var tween2 = create_tween().set_ease(Tween.EASE_OUT)
				tween2.tween_property(self, "aim_rotation:x", aim_rotation.x + deg_to_rad(gun.kickback_magnitude) / 3, 0.01)
				Globals.noise_controller.create_noise_event(gun.fire_point.global_position, self, gun.bullet_stats.noise_radius)
				if gun.fire_type == gun.fire_types.pump:
					gun.shoot_cooldown_timer.stop()
					await get_tree().create_timer(0.25).timeout
					gun.anim_player.play("pump")
		if Input.is_action_pressed("aim") and gun_state != gun_states.ads and gun and gun is Gun:
			change_gun_state(gun_states.ads)
	if !Input.is_action_pressed("aim") and gun_state == gun_states.ads and gun is Gun:
		change_gun_state(gun_states.point)
	
	# throw grenade
	#if Input.is_action_just_pressed("grenade"):
		#var inst = Globals.create_instance(grenade, grenade_spawn.global_position)
		#inst.rotation = camera.rotation
		#inst.apply_force((Vector3.UP * 500) + -camera.global_transform.basis.z * 750)
	
	# reload
	if Input.is_action_just_pressed("reload") and gun and gun is Gun:
		if gun.jammed:
			if gun_state != gun_states.unjam:
				change_gun_state(gun_states.unjam)
		elif gun_state != gun_states.reload:
			var _ammo = PlayerStats.inventory.find_item(gun.ammo_item.title)
			if !_ammo or ammo == gun.max_ammo:
				return
			change_gun_state(gun_states.reload)
	
	# interact tooltip
	if interact_cast.is_colliding():
		var collider = interact_cast.get_collider(0)
		if !collider:
			return
		if "interaction_object" in collider:
			collider = collider.interaction_object
		if collider is InteractableObject:
			Globals.ui.set_tooltip(collider)
			if Input.is_action_just_pressed("next_gun"):
				collider.index = wrapi(collider.index + 1, 0, collider.actions.size())
			elif Input.is_action_just_pressed("last_gun"):
				collider.index = wrapi(collider.index - 1, 0, collider.actions.size())
	elif Globals.ui.custom_tooltip == "":
		Globals.ui.hide_tooltip()
	
	# interact
	if Input.is_action_just_pressed("interact"):
		if !interact_cast.is_colliding():
			return
		var collider = interact_cast.get_collider(0)
		if collider is InteractableObject:
			collider.interact()
		elif "interaction_object" in collider:
			collider.interaction_object.interact()
		else:
			if collider is ItemPickup:
				collider.pickup()
			else:
				collider = collider.get_parent()
				if collider is ItemPickup:
					collider.pickup()
	
	# camera zoom
	var target_fov
	var tool = PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.tool]
	if Input.is_action_pressed("aim") and gun_state == gun_states.no_gun and tool and tool.title == "Binoculars":
		camera_zoom = zoom_levels.zoom
		Globals.ui.binocular_overlay.show()
	elif gun_state == gun_states.ads:
		camera_zoom = zoom_levels.ads
	else:
		camera_zoom = zoom_levels.regular
		Globals.ui.binocular_overlay.hide()
		
	match (camera_zoom):
		zoom_levels.regular:
			target_fov = base_fov
			mouse_sensitivity = 0.004
			controller_sensitivity = 0.04
		zoom_levels.ads:
			target_fov = base_fov / gun.zoom_amount
			mouse_sensitivity = 0.003 * ((base_fov / gun.zoom_amount) / base_fov)
			controller_sensitivity = 0.02 * ((base_fov / gun.zoom_amount) / base_fov)
		zoom_levels.zoom:
			target_fov = 10.0
			mouse_sensitivity = 0.0005
			controller_sensitivity = 0.005
	camera.fov = lerp(camera.fov, target_fov, 30.0 * delta)
	
	# light
	spot_light.visible = tool != null and tool.title == "Flashlight"
	
	# breath
	if is_holding_breath:
		current_breath -= delta
	elif current_breath < max_breath:
		current_breath += delta
	
	# commanding allies
	if Input.is_action_pressed("command_allies"):
		if Input.is_action_just_pressed("slot_1"):
			for ally in PlayerStats.ally_npcs:
				ally.goal = ally.goals.follow
			ally_destination = Vector3.ZERO
			Globals.survival_ui.create_notification("Allies will follow you")
		elif Input.is_action_just_pressed("slot_2"):
			ally_raycast.enabled = true
			ally_raycast.force_raycast_update()
			if ally_raycast.is_colliding():
				ally_destination = ally_raycast.get_collision_point()
			else:
				ally_destination = ally_raycast.get_child(0).global_position
				ally_destination.y = Globals.get_heightmap_position(ally_destination)
			for ally in PlayerStats.ally_npcs:
				ally.goal = ally.goals.travel
				ally.destination = ally_destination
				ally.change_state(ally.states.walk)
			Globals.survival_ui.create_notification("Allies going forward")
		elif Input.is_action_just_pressed("slot_3"):
			for ally in PlayerStats.ally_npcs:
				ally.goal = ally.goals.guard
			ally_destination = Vector3.ZERO
			Globals.survival_ui.create_notification("Allies will stay put")
		elif Input.is_action_just_pressed("slot_4"):
			PlayerStats.allies_shoot = true
			Globals.survival_ui.create_notification("Allies will open fire")
		elif Input.is_action_just_pressed("slot_5"):
			PlayerStats.allies_shoot = false
			Globals.survival_ui.create_notification("Allies will hold fire")
	
	# point gun up if colliding
	if gun_collision_cast.is_colliding():
		if gun_state != gun_states.point_up and gun_state != gun_states.no_gun and gun_state != gun_states.reload and (!gun or (gun and PlayerStats.gun is EquipmentGun)):
			change_gun_state(gun_states.point_up)
	elif gun_state == gun_states.point_up:
		change_gun_state(gun_states.point)
	
	# make sure we actually have a gun
	if PlayerStats.gun == null and gun_state != gun_states.no_gun:
		change_gun_state(gun_states.no_gun)
	
	# walking animation
	if gun:
		if (input.x or input.y) and gun_state == gun_states.point and is_on_floor():
			walk_time += delta
			if speed == run_speed:
				walk_time += delta * 0.25
				if gun.rotation.y == 0:
					if walk_tween:
						walk_tween.kill()
					walk_tween = create_tween()
					walk_tween.tween_property(gun, "rotation:y", deg_to_rad(45), 0.2)
			else:
				if gun.rotation.y > 0 and !walk_tween.is_running():
					if walk_tween:
						walk_tween.kill()
					walk_tween = create_tween()
					walk_tween.tween_property(gun, "rotation:y", 0, 0.2)
			var bob = cos(walk_time * 20) * 0.25
			gun.position.y += bob * delta
			var sway = cos(walk_time * 10) * 0.25
			gun.position.x += sway * delta
		elif gun and walk_time != 0: 
			walk_time = 0
			if walk_tween:
				walk_tween.kill()
			walk_tween = create_tween().set_parallel()
			walk_tween.tween_property(gun, "position", Vector3.ZERO, 0.1)
			walk_tween.tween_property(gun, "rotation:y", 0, 0.1)
	
	# walking sfx
	if (input.x or input.y) and is_on_floor():
		footstep_timer += delta
		if speed == run_speed:
			footstep_timer += delta * 0.25
		var time_to_sound = 0.35
		if speed < base_speed:
			time_to_sound = 0.45
		if footstep_timer >= time_to_sound:
			footstep_sfx.play()
			footstep_timer = 0.0


func enter_pause():
	velocity.x = 0
	velocity.z = 0


func state_pause(_delta):
	move_and_slide()


func enter_dead():
	gun_pivot.hide()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(gun_anchor, "position", Vector3.DOWN, 0.25)
	tween.tween_property(camera, "position:y", -1, 0.5)
	tween.tween_property(camera, "rotation:z", deg_to_rad(45), 1)
	tween.set_parallel(false)
	#tween.tween_callback(Globals.survival_ui.hide_all_ui)
	tween.tween_callback(UiController.open_interface.bind(Globals.survival_ui.death_menu, false))


func state_dead(_delta):
	pass


func exit_dead():
	gun_pivot.show()
	camera.current = true
	player_radgoll.reset()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(camera, "position:y", 0, 0.25)
	tween.tween_property(camera, "rotation:z", deg_to_rad(0), 0.25)
	tween.tween_property(gun_anchor, "position", Vector3.ZERO, 0.25)
	tween.tween_callback(Globals.survival_ui.show_ui)
	hitbox.revive()


func enter_gun_state_point():
	if gun_tween:
		gun_tween.kill()
	gun_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	gun_tween.tween_property(gun_anchor, "position", Vector3.ZERO, 0.25)
	gun_tween.tween_property(gun_anchor, "rotation", Vector3.ZERO, 0.25)
	gun_tween.tween_property(gun, "visible", true, 0)
	camera_zoom = zoom_levels.regular


func enter_gun_state_ads():
	if gun_tween:
		gun_tween.kill()
	gun_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	gun_tween.tween_property(gun_anchor, "position", ads_position.position, 0.15)
	#gun_tween.tween_property(gun, "visible", true, 0)
	camera_zoom = zoom_levels.ads
	sway_noise.seed = randi()
	sway_time = 0
	if gun.scope_texture:
		Globals.ui.show_scope(gun.scope_texture)
		gun.hide()


func gun_state_ads(delta: float) -> void:
	var current_sway_speed = sway_speed
	if Input.is_action_just_pressed("hold_breath") and current_breath > 0.0 and can_hold_breath:
		is_holding_breath = true
	if Input.is_action_just_released("hold_breath"):
		is_holding_breath = false
	if is_holding_breath:
		current_sway_speed = sway_speed_hold_breath
		if current_breath <= 0:
			can_hold_breath = false
			is_holding_breath = false
	elif current_breath < max_breath:
		if !can_hold_breath and current_breath > 1:
			can_hold_breath = true
	sway_time += delta * current_sway_speed
	var sway_modifier: float = 1
	if PlayerStats.soberness < PlayerStats.max_soberness:
		sway_modifier = 2
	var x_offset = sway_noise.get_noise_2d(sway_time, 0.0) * (sway_intensity - PlayerStats.skills.guns * 0.2)
	var y_offset = sway_noise.get_noise_2d(0.0, sway_time) * (sway_intensity - PlayerStats.skills.guns * 0.2)
	rotation.y += deg_to_rad(y_offset * sway_modifier)
	camera.rotation.x += deg_to_rad(x_offset * sway_modifier)


func exit_gun_state_ads() -> void:
	is_holding_breath = false
	can_hold_breath = true
	if gun.scope_texture:
		Globals.ui.hide_scope()
		gun.show()


func enter_gun_state_reload() -> void:
	var anim_player: AnimationPlayer = gun.get_node("AnimationPlayer")
	anim_player.play("reload")


func exit_gun_state_reload() -> void:
	gun.can_shoot = true
	if gun.ammo_item.title.to_lower().contains("shotgun"):
		return
	var _ammo = find_item(gun.ammo_item.title)
	use_item("", _ammo, gun.gun_stats)


func enter_gun_state_ammo_check():
	var ammo_text = gun.get_node("Label3D")
	ammo_text.text = str(gun.ammo)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(gun_anchor, "rotation:y", deg_to_rad(80), 0.25)
	tween.tween_property(gun_anchor, "position:y", 0.02, 0.25)
	tween.set_parallel(false)
	tween.tween_property(ammo_text, "visible", true, 0)


func exit_gun_state_ammo_check():
	var ammo_text = gun.get_node("Label3D")
	ammo_text.hide()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(gun_anchor, "rotation:y", 0, 0.15)
	tween.tween_property(gun_anchor, "position", Vector3.ZERO, 0.15)
	tween.set_parallel(false)
	tween.tween_property(ammo_text, "visible", false, 0)
	await tween.finished


func enter_gun_state_no_gun():
	for i in gun_anchor.get_children():
		i.process_mode = PROCESS_MODE_DISABLED
	if !gun:
		for g in gun_anchor.get_children():
			g.visible = false
	if gun_tween:
		gun_tween.kill()
	gun_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	gun_tween.tween_property(gun_anchor, "position", Vector3(0, -0.3, 0.3), 0.25)
	gun_tween.tween_property(gun_pivot, "rotation_degrees", Vector3(-45, 0, 0), 0.25)
	gun_tween.set_parallel(false)
	if gun:
		gun_tween.tween_property(gun, "visible", false, 0)
	await gun_tween.finished


func gun_state_no_gun(_delta: float):
	pass
	#if object_to_place == null:
		#return
	#placer_raycast.global_position = place_position.global_position
	#placer_raycast.enabled = true
	#if placer_raycast.is_colliding():
		#object_to_place.global_position = placer_raycast.get_collision_point()
	#if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("shoot"):
		#var item_transform = object_to_place.global_transform
		#place_position.remove_child(object_to_place)
		#get_tree().current_scene.add_child(object_to_place)
		#object_to_place.global_transform = item_transform
		#for child in object_to_place.get_children():
			#if child is MeshInstance3D:
				#child.transparency = 0
		#object_to_place = null
		#PlayerStats.delete_current_equip()


func exit_gun_state_no_gun():
	#placer_raycast.enabled = false
	gun_pivot.rotation_degrees = Vector3(-45, 0, 0)
	if gun_tween:
		gun_tween.kill()
	gun_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	gun_tween.tween_property(gun_anchor, "position", Vector3.ZERO, 0.25)
	gun_tween.tween_property(gun_pivot, "rotation_degrees", Vector3.ZERO, 0.25)
	gun_tween.set_parallel(false)
	gun_tween.tween_property(gun, "visible", true, 0)
	gun_tween.tween_property(gun, "process_mode", PROCESS_MODE_ALWAYS, 0)
	await gun_tween.finished


func enter_gun_state_point_up() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(gun_anchor, "rotation:x", deg_to_rad(90), 0.25)
	tween.tween_property(gun_anchor, "position:y", -0.3, 0.25)
	await tween.finished


func gun_state_point_up(delta: float) -> void:
	var dis = gun_collision_cast.global_position.distance_to(gun_collision_cast.get_collision_point())
	var target_z = 0.0
	if dis < 0.5:
		if dis > 0.3:
			target_z = 0.5 - dis
		else:
			target_z = 0.2
	gun_anchor.position.z = lerp(gun_anchor.position.z, target_z, 20 * delta)


func exit_gun_state_point_up() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(gun_anchor, "rotation:x", deg_to_rad(0), 0.25)
	tween.tween_property(gun_anchor, "position:y", 0, 0.25)
	tween.tween_property(gun_anchor, "position:z", 0, 0.25)
	await tween.finished


func enter_gun_state_unjam() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	tween.tween_property(gun_anchor, "position", Vector3(0, -0.25, 0.1), 0.25)
	tween.tween_property(gun_anchor, "rotation:y", deg_to_rad(45), 0.25)
	tween.tween_property(gun_anchor, "rotation:x", deg_to_rad(-25), 0.25)
	tween.set_parallel(false)
	tween.tween_interval(1.5)
	tween.tween_property(gun, "jammed", false, 0)
	tween.tween_callback(Globals.ui.hide_tooltip)
	tween.tween_callback(change_gun_state.bind(gun_states.point))


func change_gun_slot(slot_index: int) -> void:
	var kit = PlayerStats.inventory.equipment_kit
	var new_gun = kit.equipment[kit.gun_slots[slot_index]]
	PlayerStats.gun = new_gun
	if slot_index == PlayerStats.gun_index:
		if gun_state == gun_states.no_gun:
			change_gun(new_gun)
		else:
			change_gun(null)
	else:
		change_gun(new_gun)
	PlayerStats.gun_index = slot_index


func change_gun(new_gun: Equipment) -> void:
	if gun and gun_state != gun_states.no_gun:
		await change_gun_state(gun_states.no_gun)
	else:
		if gun_tween and gun_tween.is_running():
			await gun_tween.finished
		gun_anchor.position.y = -0.3
	if !new_gun:
		gun = null
		return
	gun = get(PlayerStats.gun.resource_name)
	for i in gun_anchor.get_children():
		if i != gun:
			i.visible = false
		else:
			if i is Gun:
				gun.gun_stats = PlayerStats.gun.gun_stats
			gun.rotation = Vector3.ZERO
			gun.visible = true
	if Input.is_action_pressed("aim") and gun is Gun:
		await change_gun_state(gun_states.ads)
	else:
		await change_gun_state(gun_states.point)


func unequip_gun() -> void:
	change_gun_state(gun_states.no_gun)
	PlayerStats.gun = null
	gun = null



func throw_grenade() -> void:
	#var inst = Globals.create_instance(grenade_object, grenade.get_child(0).global_position)
	var inst = grenade_object.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = grenade.get_child(0).global_position
	inst.rotation = camera.rotation
	inst.apply_force((Vector3.UP * 500) + -camera.global_transform.basis.z * 750)
	var grenade_item = PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.secondary_gun]
	PlayerStats.inventory.remove_item(grenade_item)
	if PlayerStats.inventory.get_item_amount(grenade_item) <= 0:
		PlayerStats.inventory.equipment_kit.equipment[EquipmentKit.slots.secondary_gun] = null
		unequip_gun()


func start_place_item(_item_to_place: String):
	pass
	#if gun != null:
		#await unequip_gun()
	#object_to_place = load(item_to_place).instantiate()
	#object_to_place.placed = false
	#place_position.add_child(object_to_place)


func end_place_item():
	if object_to_place:
		object_to_place.queue_free()


func use_item(item_name: String, item_id = null, target = null):
	var item
	if item_id:
		item = item_id
	else:
		item = find_item(item_name)
	if item == null:
		return
	if item is ItemUsable:
		#if !item.used_up.is_connected(PlayerStats.inventory._on_use_item):
			#item.used_up.connect(PlayerStats.inventory._on_use_item.bind(item))
		item.use(target)
	#PlayerStats.inventory.remove_item(item)


func find_item(item_name: String) -> Resource:
	return PlayerStats.inventory.find_item(item_name)


func step_noise_event():
	if !Globals.noise_controller:
		return
	var step_radius = 25
	if speed == walk_speed:
		step_radius = 15
	if speed == run_speed:
		step_radius = 45
	step_radius -= 2 * PlayerStats.skills.stealth
	Globals.noise_controller.create_noise_event(global_position, self, step_radius)


func face_center(vector: Vector3 = Vector3(0, camera.position.y, 0)):
	look_at(vector)
	aim_rotation = rotation


func check_reload_ammo(time_to_skip_to: float):
	var _ammo = find_item(gun.ammo_item.title)
	use_item(_ammo.resource_name, _ammo, gun.gun_stats)
	_ammo = find_item(gun.ammo_item.title)
	if !_ammo:
		gun.get_node("AnimationPlayer").seek(time_to_skip_to, true, true)
		gun.get_node("AnimationPlayer").seek(time_to_skip_to, true, true)
	elif ammo >= gun.max_ammo:
		gun.get_node("AnimationPlayer").seek(time_to_skip_to, true, true)


func _on_damaged(hit_position: Vector3, hit_direction: Vector3, _shooter: Node3D) -> void:
	hitbox.damage_modifier = PlayerStats.inventory.equipment_kit.get_damage_modifier()
	Globals.ui.play_hit_effect(hit_direction)
	if health_component.hp <= 0:
		player_radgoll.start_ragdoll(hit_position, hit_direction, gun)


func _on_death() -> void:
	UiController.close_all()
	PlayerStats.change_state(PlayerStats.states.dead)
	if gun:
		gun_state = gun_states.point


func _on_gun_changed() -> void:
	if PlayerStats.gun:
		if gun_state == gun_states.point or gun_state == gun_states.no_gun or gun == null:
			change_gun(PlayerStats.gun)
	else:
		unequip_gun()


func _on_step_timer_timeout() -> void:
	step_noise_event()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ladder"):
		on_ladder = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("ladder"):
		on_ladder = false
		velocity.y = 0


func _on_bullet_listener_area_entered(_area: Area3D) -> void:
	bullet_flyby_sfx.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pump":
		gun.can_shoot = true
	if anim_name == "reload":
		change_gun_state(gun_states.point)


func _on_breath_timer_timeout() -> void:
	pass # Replace with function body.
