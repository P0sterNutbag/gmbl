extends CharacterBody3D
class_name Player

@export var items: Array[Item]
enum states {walk, dead}
enum zoom_levels {regular, ads, zoom}
var state = states.walk
var camera_zoom = zoom_levels.regular
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
var punch_dmg := 1.0
var heavy_punch_dmg := 3.0
var punch_charge := 1.0
var walk_time := 0.0
var is_crouching: bool
var on_ladder: bool
var firepoint: Node3D
var ammo: Array
@onready var camera = $CameraAnchor/Camera3D
@onready var gun_anchor = $CameraAnchor/Camera3D/Guns
@onready var pistol: Node3D = $CameraAnchor/Camera3D/Guns/Pistol
@onready var silenced_pistol: Node3D = $CameraAnchor/Camera3D/Guns/SilencedPistol
@onready var rifle: Node3D = $CameraAnchor/Camera3D/Guns/AssaultRifle
@onready var sniper_rifle: Node3D = $CameraAnchor/Camera3D/Guns/SniperRifle
@onready var shotgun: Node3D = $CameraAnchor/Camera3D/Guns/Shotgun
@onready var animation_player = $CameraAnchor/Camera3D/Guns/Pistol/AnimationPlayer
@onready var muzzel_raycast  = $CameraAnchor/Camera3D/Guns/Pistol/Gun/FirePoint/RayCast3D
@onready var shoot_component: Node = $ShootComponent
@onready var step_timer: Timer = $StepTimer
@onready var interact_cast: = $CameraAnchor/Camera3D/RayCast3D
@onready var fist_anim_player: AnimationPlayer = $CameraAnchor/Camera3D/Guns/Fist/AnimationPlayer
@onready var fist_raycast: RayCast3D = $CameraAnchor/Camera3D/Guns/Fist/RayCast3D
@onready var hitbox: HealthComponent = $Hitbox
@onready var guns = [pistol, rifle]
signal shoot


func _ready() -> void:
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for gun in gun_anchor.get_children():
		gun.visible = false
	change_gun(0)
	shoot.connect(shoot_component._on_shoot)

func _physics_process(delta):
	# apply gravity
	velocity.y += -gravity * delta
	
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
			if (input.x or input.y) and !Input.is_action_pressed("aim"):
				walk_time += delta
				var bob = cos(walk_time * 20) * 0.25
				gun_anchor.position.y += bob * delta
			elif gun_anchor.position.y: 
				walk_time = 0
				var tween = create_tween()
				tween.tween_property(gun_anchor, "position:y", 0, 0.1)
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
			var gun_model = gun.get_child(0)
			var gun_pos_offset = gun.position
			var gun_target_pos: Vector3
			if Input.is_action_pressed("shoot"):
				if gun.ammo <= 0 or !gun.can_shoot:
					return
				var tween = create_tween().set_ease(Tween.EASE_OUT)
				tween.tween_property(gun_model, "position:z", 0.2, 0.01)
				tween.tween_property(gun_model, "position:z", 0, 0.2)
				shoot.emit()
				gun._on_shoot()
				camera.screen_shake()
				camera.kickback(gun.kickback_magnitude)
				Globals.noise_controller.create_noise_event(firepoint.global_position, gun.bullet_stats.noise_radius)
			if Input.is_action_pressed("aim"):
				gun_target_pos = gun.ads_vector
				camera_zoom = zoom_levels.ads
				#print(gun.get_child(0).mesh.get_aabb().size)
			else:
				gun_target_pos = Vector3.ZERO
				camera_zoom = zoom_levels.regular
			gun_model.position = lerp(gun_target_pos, gun_model.position, 30 * delta)
			
			# reload
			if Input.is_action_just_pressed("reload"):
				var ammo = find_item(gun.ammo_type)
				if !ammo:
					return
				Globals.ui.set_mag_count(get_item_amount(gun.ammo_type) - 1)
				var tween = create_tween()
				tween.tween_property(gun_model, "position:y", -1, 0.25)
				tween.tween_callback(use_item.bind("", ammo, gun))
				tween.tween_property(gun_model, "position:y", 0, 0.25)
			
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
			
			# punch
			if Input.is_action_pressed("punch"):
				punch_charge -= delta
			if Input.is_action_just_released("punch"):
				if punch_charge <= 0:
					fist_anim_player.speed_scale = 2
				else:
					fist_anim_player.speed_scale = 1
				fist_anim_player.play("punch")
			
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
				Globals.ui.hide_crosshairs()
				if gun.scope_texture != null:
					Globals.ui.show_scope(gun.scope_texture)
					gun_model.hide()
			elif Input.is_action_just_released("aim"):
				Globals.ui.show_crosshairs()
				Globals.ui.scope.hide()
				gun_model.show()
				
		states.dead:
			pass
	
	# set crosshair position
	if muzzel_raycast.is_colliding():
		var pos = camera.unproject_position(muzzel_raycast.get_collision_point())
		Globals.ui.set_crosshair_position(pos)
	else:
		Globals.ui.reset_crosshair_position()


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
	animation_player.play("put_down")
	await animation_player.animation_finished
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
			animation_player = gun.get_node("AnimationPlayer")
			firepoint = gun.get_node("Gun/FirePoint")
			muzzel_raycast = gun.get_node("Gun/FirePoint/RayCast3D")
			animation_player.play("draw")
			shoot_component.firepoint = firepoint
			shoot_component.bullet_stats = gun.bullet_stats
			await get_tree().create_timer(0.05).timeout
			gun.visible = true
	Globals.ui.set_mag_count(get_item_amount(guns[new_index].ammo_type))


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


func check_punch():
	var enemy = fist_raycast.get_collider()
	if enemy != null:
		var dmg = punch_dmg
		if punch_charge <= 0:
			dmg = heavy_punch_dmg
		enemy.damage(dmg)
	punch_charge = 1.0


func step_noise_event():
	Globals.noise_controller.create_noise_event(global_position)


func _on_damaged() -> void:
	Globals.ui.play_hit_effect()


func _on_death() -> void:
	state = states.dead
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "position:y", -1, 0.5)
	tween.tween_property(camera, "rotation:z", deg_to_rad(45), 1)
	tween.tween_callback(get_tree().reload_current_scene)

#
#func _on_step_timer_timeout() -> void:
	#step_noise_event()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("ladder"):
		on_ladder = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("ladder"):
		on_ladder = false
		velocity.y = 0
