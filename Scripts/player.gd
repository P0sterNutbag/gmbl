extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 8
var jump_speed = 5
var mouse_sensitivity = 0.004
var lean_angle = 0.0
var gun_index = 0
var bullet = preload("res://Scenes/bullet.tscn")
var firepoint
@onready var camera = $Camera3D
@onready var pistol = $Camera3D/Pistol
@onready var rifle = $Camera3D/AssaultRifle
@onready var animation_player = $Camera3D/Pistol/AnimationPlayer
@onready var muzzel_raycast  = $Camera3D/Pistol/Gun/FirePoint/RayCast3D
@onready var guns = [pistol, rifle]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for gun in guns:
		gun.visible = false
	change_gun(0)


func _physics_process(delta):
	velocity.y += -gravity * delta
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = movement_dir.x * speed
	velocity.z = movement_dir.z * speed

	move_and_slide()
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed


func _process(delta: float) -> void:
	# combat animations
	if Input.is_action_just_pressed("shoot"):
		animation_player.play("shoot")
		#var inst = Globals.create_instance(bullet, firepoint.global_position)
		var inst: Node3D = bullet.instantiate()
		inst.global_transform = firepoint.global_transform
		get_tree().current_scene.add_child(inst)
	if Input.is_action_pressed("aim"):
		animation_player.play("ads")
	if Input.is_action_just_released("aim"):
		animation_player.play("idle")
	
	# change gun
	if Input.is_action_just_released("next_gun"):
		gun_index = wrap(gun_index - 1, 0, guns.size())
		change_gun(gun_index)
	if Input.is_action_just_released("last_gun"):
		gun_index = wrap(gun_index + 1, 0, guns.size())
		change_gun(gun_index)
	
	# leaning
	if is_on_floor():
		lean_angle = 15.0 * Input.get_axis("lean_right", "lean_left")
	else:
		lean_angle = 0.0
	rotation_degrees.z = lerp(rotation_degrees.z, lean_angle, 10 * delta)
	
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
