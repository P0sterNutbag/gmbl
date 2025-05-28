extends CharacterBody3D

enum camera_types {overhead, fps}
var camera_type = camera_types.overhead
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sensitivity := 0.004
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var model: Node3D = $EnemyModel
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var camera: Camera3D = $CameraAnchor/FirstPersonCamera
@onready var ray_cast: RayCast3D = $CameraAnchor/FirstPersonCamera/RayCast3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _enter_tree() -> void:
	Globals.player = self


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (camera_anchor.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if camera_type != camera_types.overhead:
		return
	
	move_and_slide()
	
	# animate
	if input_dir != Vector2.ZERO:
		animation_player.play("Walk")
	else:
		animation_player.play("Idle")
	if direction != Vector3.ZERO:
		model.look_at(global_position + direction)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("aim"):
		camera.current = true
		camera_type = camera_types.fps
		camera.rotation.x = 0
	elif Input.is_action_just_released("aim"):
		camera.current = false
		camera_type = camera_types.overhead
	Globals.ui.hide_encounter_info()
	if Input.is_action_pressed("aim"):
		if ray_cast.is_colliding():
			var encounter = ray_cast.get_collider()
			Globals.ui.show_encounter_info(encounter)
			if Input.is_action_just_pressed("shoot"):
				encounter.start_encounter()


func _input(event):
	if event is InputEventMouseMotion:
		match camera_type:
			camera_types.overhead:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity)
			camera_types.fps:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity)
				camera.rotate_x(-event.relative.y * mouse_sensitivity)
				camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))
