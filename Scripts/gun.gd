extends Node3D
class_name Gun

@export var uses_input: bool
@export var bullet_stats: BulletStats
@export var gun_stats: GunStats = GunStats.new()
@export var ammo_item: ItemUsable
enum fire_types {semi_auto, auto, pump}
@export var fire_type: fire_types
@export var can_change_fire_type: bool
@export var shoot_cooldown: float = 0.1
@export var bullet_spread = 1.0
@export var ads_spread_mod = 0.0
@export var zoom_amount: float = 1.25
@export var engagement_range: float = 50.0
@export var kickback_magnitude: float = 3.0
@export var spread_curve := (preload("res://Resources/Curves/bullet_spread.tres"))
@export var ads_vector: Vector3
@export var scope_texture: Texture2D
@export var cast_shadow: bool = true
@export var slot: EquipmentKit.slots
@export var create_shell_on_shoot: bool = true
var ammo: int:
	get(): return gun_stats.ammo
	set(value): 
		ammo = value
		gun_stats.ammo = value
var max_ammo: int
var time_since_shot: float
var time_shooting: float
var modified_spread: float:
	get():
		modified_spread = bullet_spread + spread_over_time
		if uses_input:
			var magnitude = clamp(Globals.player.velocity.length(), 1, 2)
			modified_spread *= magnitude
			var stats = PlayerStats.skills
			modified_spread = clamp(modified_spread - (stats.guns * 0.1), 0.0, 360.0)
		return modified_spread
var spread_over_time := 0.0
var can_shoot: bool = true
var has_released: bool = true
var jammed: bool = false
var sway_vector: Vector3
var anim_player: AnimationPlayer
@export var shell: PackedScene = preload("res://Scenes/Effects/Particles/shell.tscn")
var smoke: PackedScene = preload("res://Scenes/Effects/Particles/gun_smoke.tscn")
@onready var gun_model: Node3D = $GunAnchor/Model
@onready var muzzle_flash: Node3D = $GunAnchor/FirePoint/MuzzleFlash
@onready var flash_texture: MeshInstance3D = $GunAnchor/FirePoint/MuzzleFlash/MeshInstance3D3
@onready var fire_point: Node3D = $GunAnchor/FirePoint
@onready var audio_player: AudioStreamPlayer3D = $GunAnchor/FirePoint/AudioStreamPlayer3D
@onready var chamber: Node3D = $GunAnchor/Chamber
@onready var empty_click: AudioStreamPlayer3D = $EmptyClick
@onready var shoot_cooldown_timer: Timer = $Cooldown


func _ready() -> void:
	max_ammo = gun_stats.ammo
	shoot_cooldown_timer.wait_time = shoot_cooldown
	anim_player = get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.animation_started.connect(_on_animation_started)


func _process(delta: float) -> void:
	if uses_input:
		time_since_shot += delta
		if fire_type == fire_types.semi_auto:
			if has_released and time_since_shot > shoot_cooldown:
				can_shoot = true
		if Input.is_action_just_released("shoot"):
			has_released = true
	if gun_stats.condition <= 0:
		can_shoot = false
	# spread
	time_shooting -= delta * 1.5
	time_shooting = clamp(time_shooting, 0, 1)
	spread_over_time = spread_curve.sample(time_shooting)


func aim_fire_point(pos: Vector3) -> void:
	fire_point.look_at(pos)


func use(shot_owner: Node3D = null) -> bool:
	if !can_shoot or gun_stats.condition <= 0.0:
		return false
	if ammo <= 0 or jammed:
		empty_click.play()
		return false
	shoot(shot_owner)
	return true


func shoot(shot_owner: Node3D = null) -> void:#is_ads: bool = false, movement_speed = Vector3.ZERO) -> void:
	# determine modifiers
	var is_ads = false
	if uses_input:
		is_ads = Globals.player.gun_state == Globals.player.gun_states.ads
	# create the bullets
	for i in bullet_stats.amount:
		create_bullet(shot_owner, is_ads)
	# adjust variables
	gun_stats.ammo -= 1
	gun_stats.condition -= 0.05
	time_shooting += 0.4
	can_shoot = false
	has_released = false
	shoot_cooldown_timer.start()
	# effects
	if create_shell_on_shoot:
		create_shell()
	flash_texture.rotate_z(deg_to_rad(randf_range(0, 360)))
	muzzle_flash.visible = true
	audio_player.pitch_scale = Engine.time_scale
	audio_player.play()
	var tween = create_tween()
	tween.tween_property(muzzle_flash, "visible", false, 0.1)
	# gun condition
	if uses_input and gun_stats.condition <= 0.0:
		Globals.survival_ui.create_notification(PlayerStats.gun.title + " has broken")
	if uses_input and gun_stats.condition < 50:
		if randf() < (50 - gun_stats.condition) * 0.002:
			jammed = true
			Globals.survival_ui.create_notification(PlayerStats.gun.title + " has jammed. Press R to unjam")


func create_bullet(shot_owner: Node3D, is_ads: bool) -> void:
	var inst = bullet_stats.bullet_scene.instantiate()
	inst.global_transform = fire_point.global_transform
	inst.scale = Vector3.ONE
	inst.visible = false
	var h_angle_variance = randf_range(-modified_spread, modified_spread * 1.1)
	if is_ads:
		h_angle_variance *= ads_spread_mod
	inst.rotate_y(deg_to_rad(h_angle_variance))
	var v_angle_variance = randf_range(-modified_spread, modified_spread)
	if is_ads:
		v_angle_variance *= ads_spread_mod
	inst.rotate_x(deg_to_rad(v_angle_variance))
	inst.bullet_stats = bullet_stats
	inst.creator = shot_owner
	get_tree().current_scene.add_child(inst)
	if uses_input and is_ads:
		inst.global_position = Globals.player.camera.global_position


func create_shell() -> void:
	var inst: RigidBody3D = shell.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_transform = chamber.global_transform
	#inst.apply_impulse(Vector3(randf_range(0.5, 1), randf_range(0.5, 1), 0))
	inst.apply_impulse(global_transform.basis.y * randf_range(1.0, 1.5) + global_transform.basis.x * randf_range(1.0, 1.5))
	inst.apply_torque_impulse(Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1)))


func _on_shoot_cooldown_timeout() -> void:
	if fire_type == fire_types.auto or !uses_input:
		can_shoot = true


func _on_animation_started(_anim_name: StringName):
	anim_player.speed_scale = 0.675 + PlayerStats.skills.guns * 0.1
