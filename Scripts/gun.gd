extends Node3D
class_name Gun

@export var bullet_stats: BulletStats
@export var ammo_type: String
enum fire_types {semi_auto, auto}
@export var fire_type: fire_types
@export var ammo: int = 8
@export var fire_timer: float
@export var zoom_amount: float = 1.25
@export var kickback_magnitude: float = 1
@export var ads_vector: Vector3
@export var scope_texture: Texture2D
@export var cast_shadow: bool = true
var max_ammo: int
var time_since_shot: float
var can_shoot: bool = true
var has_released: bool = true
var sway_vector: Vector3
var shoot_timer: Timer
var shell: PackedScene = preload("res://Scenes/Particles/shell.tscn")
@onready var gun_model: Node3D = $GunAnchor/Model
@onready var muzzle_flash: Node3D = $GunAnchor/FirePoint/MuzzleFlash
@onready var flash_texture: MeshInstance3D = $GunAnchor/FirePoint/MuzzleFlash/MeshInstance3D3
@onready var fire_point: Node3D = $GunAnchor/FirePoint
@onready var audio_player: AudioStreamPlayer3D = $GunAnchor/FirePoint/AudioStreamPlayer3D
@onready var chamber: Node3D = $GunAnchor/Chamber


func _ready() -> void:
	max_ammo = ammo
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 0.1
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	#muzzle_flash.hide()
	add_child(shoot_timer)
	if !cast_shadow:
		for child in gun_model.get_child(0).get_children():
			child.cast_shadow = false


func _process(delta: float) -> void:
	time_since_shot += delta
	if fire_type == fire_types.semi_auto:
		if has_released and time_since_shot > fire_timer:
			can_shoot = true
	if Input.is_action_just_released("shoot"):
		has_released = true


func aim_fire_point(pos: Vector3) -> void:
	fire_point.look_at(pos)


func _on_shoot() -> void:
	ammo -= 1
	can_shoot = false
	has_released = false
	time_since_shot = 0
	shoot_timer.start()
	flash_texture.rotate_z(deg_to_rad(randf_range(0, 360)))
	muzzle_flash.visible = true
	audio_player.play()
	var shell_instance = Globals.create_particle(shell, chamber.global_position, chamber)
	if shell_instance != null:
		shell_instance.apply_impulse(global_transform.basis.x * randf_range(2, 4) + global_transform.basis.y * randf_range(2, 3))
		shell_instance.apply_torque(Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)))
	var tween = create_tween()
	tween.tween_property(muzzle_flash, "visible", false, 0.1)


func _on_shoot_timer_timeout() -> void:
	if fire_type == fire_types.auto:
		can_shoot = true
