extends CharacterBody3D
class_name Player

@export var items: Array[Item]
enum states {walk, dead}
enum zoom_levels {regular, ads, zoom}
enum gun_states {point, ads, reload}
var state = states.walk
var camera_zoom = zoom_levels.regular
var gun_state = gun_states.point
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var base_speed := 8.0
var crouch_speed := 3.0
var speed = base_speed
var jump_speed := 8.0
var mouse_sensitivity := 0.004
var lean_angle := 0.0
var gun_index := -1
var crouch_height := 1.0
var base_fov := 75.0
var walk_time := 0.0
var is_crouching: bool
var on_ladder: bool
var firepoint: Node3D
var ammo: Array
var grenade = preload("res://Scenes/Bullets/grenade.tscn")
@onready var camera = $CameraAnchor/Camera3D
@onready var gun_anchor: Node3D = $CameraAnchor/Camera3D/GunOffset/GunAnchor
@onready var gun_offset: Node3D = $CameraAnchor/Camera3D/GunOffset
@onready var ads_position: Node3D = $CameraAnchor/Camera3D/AdsOffset/AdsPosition
@onready var pistol: Node3D = $CameraAnchor/Camera3D/GunOffset/GunAnchor/Pistol
@onready var rifle: Node3D = $CameraAnchor/Camera3D/GunOffset/GunAnchor/AK47
@onready var sniper_rifle: Node3D = $CameraAnchor/Camera3D/GunOffset/GunAnchor/SniperRifle
@onready var shotgun: Node3D = $CameraAnchor/Camera3D/GunOffset/GunAnchor/Shotgun
@onready var shoot_component: Node = $ShootComponent
@onready var step_timer: Timer = $StepTimer
@onready var interact_cast: = $CameraAnchor/Camera3D/RayCast3D
@onready var hitbox: HealthComponent = $Hitbox
@onready var grenade_spawn: Node3D = $CameraAnchor/Camera3D/GrenadeSpawn
@onready var guns = [pistol, rifle]


func _ready() -> void:
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hitbox.hp_bar = Globals.ui.player_hp_bar
	for gun in gun_anchor.get_children():
		gun.visible = false
	change_gun(0)


func _physics_process(delta):
	# apply gravity
	velocity.y += -gravity * delta
	# state machine
	match state:
		states.walk:
			# set speed
			if is_crouching:
				speed = crouch_speed
			else:
				speed = base_speed
			
			# get and apply inputs
			var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
			velocity.x = movement_dir.x * speed
			velocity.z = movement_dir.z * speed
			
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
			
			# walking animation
			var gun = guns[gun_index]
			if (input.x or input.y) and !Input.is_action_pressed("aim"):
				walk_time += delta
				var bob = cos(walk_time * 20) * 0.25
				gun.position.y += bob * delta
			elif gun.position.y: 
				walk_time = 0
				var tween = create_tween()
				tween.tween_property(gun, "position:y", 0, 0.1)
				await tween.finished
			
		states.dead:
			pass


func _process(delta: float) -> void:
	match state:
		states.walk:
			# change gun
			if Input.is_action_just_released("next_gun") and guns.size() > 1:
				change_gun(wrap(gun_index - 1, 0, guns.size()))
			elif Input.is_action_just_released("last_gun") and guns.size() > 1:
				change_gun(wrap(gun_index + 1, 0, guns.size()))
			elif Input.is_action_just_pressed("slot_1"):
				change_gun(0)
			elif Input.is_action_just_pressed("slot_2"):
				change_gun(1)
			elif Input.is_action_just_pressed("slot_3"):
				change_gun(2)
			elif Input.is_action_just_pressed("slot_4"):
				change_gun(3)
			
			# leaning
			if is_on_floor():
				lean_angle = 20.0 * Input.get_axis("lean_right", "lean_left")
			else:
				lean_angle = 0.0
			rotation_degrees.z = lerp(rotation_degrees.z, lean_angle, 10 * delta)
			
			# crouching
			if Input.is_action_just_pressed("crouch") and is_on_floor():
				is_crouching = !is_crouching
			var cam_target_pos = Vector3.ZERO
			if is_crouching:
				cam_target_pos = Vector3.DOWN * crouch_height
			camera.position = lerp(camera.position, cam_target_pos, 10 * delta)
			
			# noise
			if abs(velocity) > Vector3.ZERO and is_on_floor() and !is_crouching:
				if step_timer.time_left <= 0:
					step_noise_event()
					step_timer.start()
			
			# gun things
			var gun = guns[gun_index]
			if gun_state != gun_states.reload:
				if Input.is_action_pressed("shoot"):
					if gun.ammo <= 0 or !gun.can_shoot:
						return
					var tween = create_tween().set_ease(Tween.EASE_OUT)
					tween.tween_property(gun, "position:z", 0.1, 0.01)
					tween.tween_property(gun, "position:z", 0, 0.2)
					shoot_component._on_shoot(Input.is_action_pressed("aim"))
					gun._on_shoot()
					camera.screen_shake()
					camera.kickback(gun.kickback_magnitude)
					Globals.noise_controller.create_noise_event(firepoint.global_position, self, gun.bullet_stats.noise_radius)
				if Input.is_action_pressed("aim"):
					gun_state = gun_states.ads
					camera_zoom = zoom_levels.ads
				else:
					gun_state = gun_states.point
					camera_zoom = zoom_levels.regular
			
			# throw grenade
			if Input.is_action_just_pressed("grenade"):
				var inst = Globals.create_instance(grenade, grenade_spawn.global_position)
				inst.rotation = camera.rotation
				inst.apply_force((Vector3.UP * 500) + -camera.global_transform.basis.z * 750)
			
			# reload
			if Input.is_action_just_pressed("reload") and gun_state != gun_states.reload:
				var ammo = find_item(gun.ammo_type)
				if !ammo:
					return
				gun_state = gun_states.reload
				Globals.ui.set_mag_count(get_item_amount(gun.ammo_type) - 1)
				var tween = create_tween()
				tween.tween_property(gun_anchor, "position:y", -1, 0.25)
				tween.tween_interval(0.5)
				tween.tween_callback(use_item.bind("", ammo, gun))
				tween.tween_property(gun_anchor, "position:y", 0, 0.15) 
				tween.tween_property(self, "gun_state", gun_states.point, 0)
			print(gun_state)
			# interact
			if Input.is_action_just_pressed("interact"):
				if !interact_cast.is_colliding():
					return
				var collider = interact_cast.get_collider(0)
				if collider is GunPickup:
					collider.pickup(self)
				else:
					collider = collider.get_parent()
					if collider is ItemPickup:
						collider.pickup(self)
				Globals.ui.set_mag_count(get_item_amount(gun.ammo_type))
				Globals.ui.set_medit_count(get_item_amount("medkit"))
			
			# heal
			if Input.is_action_just_pressed("heal"):
				var medkit = find_item("medkit")
				if medkit:
					use_item("", medkit, hitbox)
					hitbox.hp = clamp(hitbox.hp, 0, hitbox.max_hp)
			
			# camera zoom
			var target_fov
			if Input.is_action_pressed("camera_zoom") and !Input.is_action_pressed("aim"):
				camera_zoom = zoom_levels.zoom
			match (camera_zoom):
				zoom_levels.regular:
					target_fov = base_fov
					mouse_sensitivity = 0.004
				zoom_levels.ads:
					mouse_sensitivity = 0.002
					target_fov = base_fov / gun.zoom_amount
					mouse_sensitivity = 0.003 * ((base_fov / gun.zoom_amount) / base_fov)
				zoom_levels.zoom:
					target_fov = 10.0
					mouse_sensitivity = 0.0005
			camera.fov = lerp(camera.fov, target_fov, 30.0 * delta)
			
			# ui
			if Input.is_action_just_pressed("aim"):
				if gun.scope_texture != null:
					Globals.ui.show_scope(gun.scope_texture)
					gun.hide()
			elif Input.is_action_just_released("aim"):
				Globals.ui.scope.hide()
				gun.show()
				
		states.dead:
			pass
	
	match gun_state:
		gun_states.point:
			gun_anchor.position = lerp(Vector3.ZERO, gun_anchor.position, 30 * delta)
		gun_states.ads:
			gun_anchor.position = lerp(ads_position.position, gun_anchor.position, 30 * delta)
		gun_states.reload:
			pass


func _input(event):
	if state == states.dead:
		return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))


func change_gun(new_index) -> void:
	if new_index > guns.size() - 1:
		return
	if new_index == gun_index: 
		guns[gun_index].visible = false
		gun_index = -1
		return
	for gun in guns:
		gun.process_mode = PROCESS_MODE_DISABLED
	guns[new_index].process_mode = PROCESS_MODE_ALWAYS
	gun_index = new_index
	for i in guns.size():
		var gun = guns[i]
		if i != gun_index:
			gun.visible = false
		else:
			firepoint = gun.get_node("GunAnchor/FirePoint")
			shoot_component.firepoint = camera
			shoot_component.tracer_firepoint = firepoint
			shoot_component.bullet_stats = gun.bullet_stats
			await get_tree().create_timer(0.05).timeout
			gun.visible = true
	Globals.ui.set_mag_count(get_item_amount(guns[new_index].ammo_type))
	Globals.ui.set_gun_name(guns[gun_index].name.to_upper())


func use_item(item_name: String, item_id = null, target: Node = self):
	var item
	if item_id:
		item = item_id
	else:
		item = find_item(item_name)
	if item == null:
		return
	item.use(target)
	if item.uses <= 0:
		items.erase(item)
	Globals.ui.set_medit_count(get_item_amount("medkit"))


func find_item(item_name: String) -> Resource:
	for i in items:
		if i != null and i.resource_name == item_name:
			return i
	return null


func get_item_amount(item_name: String) -> int:
	if items.size() <= 0:
		return 0
	return items.filter(func(i): return i != null and i.resource_name == item_name).size()


func step_noise_event():
	if !Globals.noise_controller:
		return
	Globals.noise_controller.create_noise_event(global_position, self)


func _on_damaged(hit_position: Vector3, hit_direction: Vector3) -> void:
	Globals.ui.play_hit_effect()


func _on_death() -> void:
	state = states.dead
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position:y", -1, 0.5)
	tween.tween_property(camera, "rotation:z", deg_to_rad(45), 1)
	tween.tween_callback(get_tree().reload_current_scene)


func _on_step_timer_timeout() -> void:
	step_noise_event()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ladder"):
		on_ladder = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("ladder"):
		on_ladder = false
		velocity.y = 0
