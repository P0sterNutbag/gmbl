extends CharacterBody3D
class_name Player

enum states {walk, dead}
var state = states.walk
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var max_hp := 100.0
var hp := max_hp: 
	set(value):
		hp = value
		Globals.ui.player_hp_bar.value = (hp / max_hp)
var base_speed := 8.0
var crouch_speed := 3.0
var speed = base_speed
var jump_speed := 8.0
var mouse_sensitivity := 0.004
var lean_angle := 0.0
var gun_index := 0
var crouch_height := 1.0
var is_crouching: bool
var firepoint: Node3D
@export var items: Array[Item]
var bullet = preload("res://Scenes/bullet.tscn")
@onready var camera = $CameraAnchor/Camera3D
@onready var pistol = $CameraAnchor/Camera3D/Pistol
@onready var rifle = $CameraAnchor/Camera3D/AssaultRifle
@onready var animation_player = $CameraAnchor/Camera3D/Pistol/AnimationPlayer
@onready var muzzel_raycast  = $CameraAnchor/Camera3D/Pistol/Gun/FirePoint/RayCast3D
@onready var shoot_component: Node = $ShootComponent
@onready var step_timer: Timer = $StepTimer
@onready var guns = [pistol, rifle]
signal shoot


func _ready() -> void:
	Globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for gun in guns:
		gun.visible = false
	change_gun(0)
	shoot.connect(shoot_component._on_shoot)


func _physics_process(delta):
	# apply gravity
	velocity.y += -gravity * delta
	
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

	move_and_slide()
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed


func _process(delta: float) -> void:
	match state:
		states.walk:
			# change gun
			if Input.is_action_just_released("next_gun"):
				gun_index = wrap(gun_index - 1, 0, guns.size())
				change_gun(gun_index)
			if Input.is_action_just_released("last_gun"):
				gun_index = wrap(gun_index + 1, 0, guns.size())
				change_gun(gun_index)
			
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
			
			# combat animations
			var gun = guns[gun_index].get_child(0)
			var gun_pos_offset = guns[gun_index].position
			var gun_target_pos: Vector3
			if Input.is_action_just_pressed("shoot"):
				var tween = create_tween().set_ease(Tween.EASE_OUT)
				tween.tween_property(gun, "position:z", 0.2, 0.01)
				tween.tween_property(gun, "position:z", 0, 0.2)
				shoot.emit()
				Globals.noise_controller.create_noise_event(firepoint.global_position, 30)
			if Input.is_action_pressed("aim"):
				gun_target_pos.x = -gun_pos_offset.x
				#gun_target_pos.y = -gun_pos_offset.y
				#print(gun.get_child(0).mesh.get_aabb().size)
				Globals.ui.crosshair.hide()
			else:
				gun_target_pos.x = 0
				gun_target_pos.y = 0
				Globals.ui.crosshair.show()
			gun.position = lerp(gun_target_pos, gun.position, 30 * delta)
			
		states.dead:
			pass
	
	# set crosshair position
	if muzzel_raycast.is_colliding():
		var pos = camera.unproject_position(muzzel_raycast.get_collision_point())
		Globals.ui.set_crosshair_position(pos)
	else:
		Globals.ui.reset_crosshair_position()


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))


func change_gun(new_index) -> void:
	animation_player.play("put_down")
	await animation_player.animation_finished
	gun_index = new_index
	for i in guns.size():
		var gun = guns[i]
		if i != gun_index:
			gun.visible = false
		else:
			gun.visible = true
			animation_player = gun.get_node("AnimationPlayer")
			firepoint = gun.get_node("Gun/FirePoint")
			muzzel_raycast = gun.get_node("Gun/FirePoint/RayCast3D")
			animation_player.play("draw")
			shoot_component.firepoint = firepoint


func use_item(index: int):
	if items.size() - 1 < index:
		return
	var item = items[index]
	item.use(self)
	if item.uses <= 0:
		items.erase(item)


func step_noise_event():
	Globals.noise_controller.create_noise_event(global_position)


func _on_damaged() -> void:
	hp -= 10


func _on_death() -> void:
	state = states.dead

#
#func _on_step_timer_timeout() -> void:
	#step_noise_event()
