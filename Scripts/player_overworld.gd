extends CharacterBody3D

enum camera_types {overhead, fps}
var camera_type = camera_types.overhead
const SPEED = 5.0
var mouse_sensitivity := 0.004
var camera_max_zoom: float = 20.0
var camera_min_zoom: float = 2.0
var camera_target_zoom: float = 10.0
var camera_zoom_incrament: float = 1
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
const NOTIFICATION = preload("uid://dl0pidlmm5dwh")
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var model: Node3D = $EnemyModel
@onready var animation_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var camera: Camera3D = $CameraAnchor/RotationOffset/OverheadCamera
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
var gun: Node3D
	#get: 
		#if !PlayerStats.gun:
			#return null
		#return get(PlayerStats.gun.resource_name)


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerStats.gun_changed.connect(_on_gun_changed)
	state_functions = {
		PlayerStats.states.walk: state_walk,
		PlayerStats.states.pause: state_pause,
		PlayerStats.states.dead: state_dead,
	}


func _enter_tree() -> void:
	Globals.player = self
	global_position.y = Globals.get_heightmap_position(global_position)
	await get_tree().process_frame
	hitbox.hp = PlayerStats.hp
	if PlayerStats.gun:
		change_gun(PlayerStats.gun)
	else:
		unequip_gun()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# zoom camera
	#if PlayerStats.state != PlayerStats.states.pause:
	if Input.is_action_just_pressed("next_gun"):
		camera_target_zoom = clamp(camera_target_zoom - camera_zoom_incrament, camera_min_zoom, camera_max_zoom)
	elif Input.is_action_just_pressed("last_gun"):
		camera_target_zoom = clamp(camera_target_zoom + camera_zoom_incrament, camera_min_zoom, camera_max_zoom)
	camera.position.z = lerp(camera.position.z, camera_target_zoom, delta * 10)
	
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
	
	# change gun
	var kit = PlayerStats.inventory.equipment_kit.gun_slots
	if Input.is_action_just_released("next_gun"):
		change_gun_slot(wrap(PlayerStats.gun_index - 1, 0, kit.size()))
	elif Input.is_action_just_released("last_gun"):
		change_gun_slot(wrap(PlayerStats.gun_index + 1, 0, kit.size()))
	elif Input.is_action_just_pressed("slot_1"):
		change_gun_slot(0)
	elif Input.is_action_just_pressed("slot_2"):
		change_gun_slot(1)
	
	# light
	var flashlight = PlayerStats.inventory.find_item("flashlight")
	if Input.is_action_just_pressed("light") and flashlight and flashlight.equipped:
		PlayerStats.flashlight_on = !PlayerStats.flashlight_on
	if PlayerStats.flashlight_on:
		spot_light.visible = true
	else:
		spot_light.visible = false
	
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


func change_gun(new_gun: EquipmentGun) -> void:
	PlayerStats.gun = new_gun
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


func create_notification(string: String) -> void:
	var inst = NOTIFICATION.instantiate()
	inst.global_position = camera.unproject_position(notification_position.global_position)
	get_tree().current_scene.add_child(inst)
	inst.label.text = string


func _input(event):
	if PlayerStats.state != PlayerStats.states.walk:
		return
	if event is InputEventMouseMotion:
		match camera_type:
			camera_types.overhead:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity * PlayerStats.sensitivity_modifier)
			camera_types.fps:
				camera_anchor.rotate_y(-event.relative.x * mouse_sensitivity * PlayerStats.sensitivity_modifier)
				camera.rotate_x(-event.relative.y * mouse_sensitivity * PlayerStats.sensitivity_modifier)
				camera.rotation.x = clampf(camera.rotation.x, -deg_to_rad(70), deg_to_rad(70))


func save() -> Dictionary:
	return {
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"model_rotation": model_rotation,
	}


func _on_gun_changed() -> void:
	if PlayerStats.gun:
		gun = get(PlayerStats.gun.resource_name)
		change_gun(PlayerStats.gun)
	else:
		unequip_gun()


func _on_damaged(_hit_position: Vector3, _hit_direction: Vector3) -> void:
	pass


func _on_death() -> void:
	PlayerStats.change_state(PlayerStats.states.dead)
	animation_player.play("Die")
	await animation_player.animation_finished
	UiController.open_interface(Globals.survival_ui.progress_menu, false)
