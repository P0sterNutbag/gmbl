extends CharacterBody3D

enum camera_types {overhead, fps}
var camera_type = camera_types.overhead
const SPEED = 5.0
var mouse_sensitivity := 0.004
var run_animation := "Run"
var idle_animation := "Idle"
var model_rotation: float:
	set(value):
		if model:
			model.rotation.y = value
	get():
		if model:
			return model.rotation.y
		else:
			return 0.0
var state_functions: Dictionary
var exit_functions: Dictionary
var enter_functions: Dictionary
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var model: Node3D = $EnemyModel
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var camera: Camera3D = $CameraAnchor/RotationOffset/OverheadCamera
@onready var gun_anchor: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var rifle: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/AK47
@onready var pistol: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/Pistol
@onready var sniper_rifle: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/SniperRifle
@onready var shotgun: Gun = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D/Shotgun
var gun: Node3D: 
	get: 
		if !PlayerStats.gun:
			return null
		return get(PlayerStats.gun.name)


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	state_functions = {
		PlayerStats.states.walk: state_walk,
		PlayerStats.states.pause: state_pause,
		PlayerStats.states.dead: state_dead,
	}


func _enter_tree() -> void:
	Globals.player = self
	await get_tree().process_frame
	change_gun(PlayerStats.gun)


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
	var direction := ((camera_anchor.transform.basis * transform.basis) * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
		animation_player.play(run_animation)
	else:
		animation_player.play(idle_animation)
	if direction != Vector3.ZERO:
		model.look_at(global_position + direction)


func state_pause(delta) -> void:
	animation_player.play(idle_animation)


func state_dead(delta) -> void:
	pass


func change_gun(new_gun: EquipmentGun) -> void:
	PlayerStats.gun = new_gun
	for i in gun_anchor.get_children():
		if i != gun:
			i.visible = false
		else:
			i.visible = true
	run_animation = "Run"
	idle_animation = "Idle"


func unequip_gun() -> void:
	if gun:
		gun.visible = false
	PlayerStats.gun = null
	run_animation = "RunNoGun"
	idle_animation = "IdleNoGun"


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


#func _on_area_3d_area_entered(area: Area3D) -> void:
	##if velocity.length() > 0:
	#Globals.ui.show_location_info(area)


#func _on_area_3d_area_exited(area: Area3D) -> void:
	#Globals.ui.hide_location_info()


func save() -> Dictionary:
	return {
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"model_rotation": model_rotation,
	}
