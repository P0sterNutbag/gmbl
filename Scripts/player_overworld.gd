extends CharacterBody3D

enum camera_types {overhead, fps}
var camera_type = camera_types.overhead
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var mouse_sensitivity := 0.004
var state_functions: Dictionary
var exit_functions: Dictionary
var enter_functions: Dictionary
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var model: Node3D = $EnemyModel
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var camera: Camera3D = $CameraAnchor/FirstPersonCamera
@onready var ray_cast: RayCast3D = $CameraAnchor/FirstPersonCamera/RayCast3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_functions = {
		PlayerStats.states.walk: state_walk,
		PlayerStats.states.pause: state_pause,
		PlayerStats.states.dead: state_dead,
	}


func _enter_tree() -> void:
	Globals.player = self


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


func state_walk(delta) -> void:
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
		animation_player.play("Run")
	else:
		animation_player.play("Idle")
	if direction != Vector3.ZERO:
		model.look_at(global_position + direction)


func state_pause(delta) -> void:
	animation_player.play("Idle")


func state_dead(delta) -> void:
	pass


func _input(event):
	if PlayerStats.state != PlayerStats.states.walk:
		return
	if event is InputEventMouseMotion:
		match camera_type:
			camera_types.overhead:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity)
			camera_types.fps:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity)
				camera.rotate_x(-event.relative.y * mouse_sensitivity)
				camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))


func _on_area_3d_area_entered(area: Area3D) -> void:
	Globals.ui.show_location_info(area)


func _on_area_3d_area_exited(area: Area3D) -> void:
	Globals.ui.hide_location_info()
