extends Node3D
class_name Gun

@export var uses_input: bool
@export var bullet_stats: BulletStats
@export var gun_stats: GunStats = GunStats.new()
@export var ammo_item: ItemUsable
enum fire_types {semi_auto, auto, pump}
@export var fire_type: fire_types
@export var shoot_cooldown: float = 0.1
@export var zoom_amount: float = 1.25
@export var kickback_magnitude: float = 1
@export var ads_vector: Vector3
@export var scope_texture: Texture2D
@export var cast_shadow: bool = true
var ammo: int:
	get(): return gun_stats.ammo
	set(value): 
		ammo = value
		gun_stats.ammo = value
var max_ammo: int
var time_since_shot: float
var time_shooting: float
var spread := 1.0
var can_shoot: bool = true
var has_released: bool = true
var sway_vector: Vector3
#var shoot_timer: Timer
var anim_player: AnimationPlayer
var shell: PackedScene = preload("res://Scenes/Particles/shell.tscn")
var smoke: PackedScene = preload("res://Scenes/Particles/gun_smoke.tscn")
var spread_curve := (preload("res://Resources/bullet_spread.tres"))
@onready var gun_model: Node3D = $GunAnchor/Model
@onready var muzzle_flash: Node3D = $GunAnchor/FirePoint/MuzzleFlash
@onready var flash_texture: MeshInstance3D = $GunAnchor/FirePoint/MuzzleFlash/MeshInstance3D3
@onready var fire_point: Node3D = $GunAnchor/FirePoint
@onready var audio_player: AudioStreamPlayer3D = $GunAnchor/FirePoint/AudioStreamPlayer3D
@onready var chamber: Node3D = $GunAnchor/Chamber
@onready var empty_click: AudioStreamPlayer3D = $EmptyClick
@onready var shoot_cooldown_timer: Timer = $Cooldown
@onready var firepoint: Node3D = $GunAnchor/FirePoint


func _ready() -> void:
	max_ammo = gun_stats.ammo
	shoot_cooldown_timer.wait_time = shoot_cooldown
	#shoot_timer = Timer.new()
	#shoot_timer.wait_time = 0.1
	#shoot_timer.one_shot = true
	#shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	anim_player = get_node_or_null("AnimationPlayer")
	#muzzle_flash.hide()
	#add_child(shoot_timer)
	#if !cast_shadow:
		#for child in gun_model.get_child(0).get_children():
			#if child is MeshInstance3D:
				#child.cast_shadow = false


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
	time_shooting -= delta * 2
	time_shooting = clamp(time_shooting, 0, 1)
	spread = lerp(1, 2, spread_curve.sample(time_shooting))



func aim_fire_point(pos: Vector3) -> void:
	fire_point.look_at(pos)


#func _on_shoot() -> void:
	#gun_stats.ammo -= 1
	#gun_stats.condition -= 0.05
	#can_shoot = false
	#has_released = false
	#flash_texture.rotate_z(deg_to_rad(randf_range(0, 360)))
	#muzzle_flash.visible = true
	#audio_player.play()
	#var tween = create_tween()
	#tween.tween_property(muzzle_flash, "visible", false, 0.1)
	##if fire_type == fire_types.pump:
		##await get_tree().create_timer(0.25).timeout
		##if anim_player:
			##anim_player.play("pump")
	##else:
	#shoot_cooldown_timer.start()
	##var shell_instance = Globals.create_particle(shell, chamber.global_position, chamber)
	##if shell_instance != null:
		##shell_instance.apply_impulse(global_transform.basis.x * randf_range(2, 4) + global_transform.basis.y * randf_range(2, 3))
		##shell_instance.apply_torque(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))


func use(shot_owner: Node3D = null) -> bool:
	if !can_shoot:
		return false
	if ammo <= 0:
		empty_click.play()
		return false
	shoot(shot_owner)
	return true
	


func shoot(shot_owner: Node3D = null) -> void:#is_ads: bool = false, movement_speed = Vector3.ZERO) -> void:
	var is_ads = false
	var movement_speed = Vector3.ZERO
	if uses_input:
		is_ads = Globals.player.gun_state == Globals.player.gun_states.ads
		movement_speed = Globals.player.velocity
	time_shooting += 0.4
	for i in bullet_stats.amount:
		var inst = bullet_stats.bullet_scene.instantiate()
		inst.global_transform = firepoint.global_transform
		inst.scale = Vector3.ONE
		inst.visible = false
		var variance = Vector2(bullet_stats.h_angle_variance_hip, bullet_stats.v_angle_variance_hip)
		if is_ads:
			variance = Vector2(bullet_stats.h_angle_variance_ads, bullet_stats.v_angle_variance_ads)
		if movement_speed:
			var magnitude = clamp(movement_speed.length(), 1, 2)
			variance *= magnitude
		variance *= spread
		var h_angle_variance = randf_range(-variance.x, variance.x * 1.1)
		inst.rotate_y(deg_to_rad(h_angle_variance))
		var v_angle_variance = randf_range(-variance.y, variance.y)
		inst.rotate_x(deg_to_rad(v_angle_variance))
		inst.bullet_stats = bullet_stats
		inst.creator = shot_owner
		#inst.bullet_stats.damage *= gun_stats.condition / 100
		inst.gun_stats = gun_stats
		get_tree().current_scene.add_child(inst)
	gun_stats.ammo -= 1
	gun_stats.condition -= 0.05
	can_shoot = false
	has_released = false
	flash_texture.rotate_z(deg_to_rad(randf_range(0, 360)))
	muzzle_flash.visible = true
	audio_player.play()
	var tween = create_tween()
	tween.tween_property(muzzle_flash, "visible", false, 0.1)
	shoot_cooldown_timer.start()



func _on_shoot_cooldown_timeout() -> void:
	if fire_type == fire_types.auto or !uses_input:
		can_shoot = true
