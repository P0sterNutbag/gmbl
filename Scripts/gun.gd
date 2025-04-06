extends Node3D

@export var bullet_stats: BulletStats
@export var ammo_type: String
enum fire_types {semi_auto, auto}
@export var fire_type: fire_types
@export var fire_timer: float
@export var zoom_amount: float = 1.25
@export var kickback_magnitude: float = 1
@export var ads_vector: Vector3
@export var scope_texture: Texture2D
var ammo: int = 10
var time_since_shot: float
var can_shoot: bool = true
var has_released: bool = true
var sway_vector: Vector3
var shoot_timer: Timer
@onready var gun_model: Node3D = $Gun


func _ready() -> void:
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 0.1
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)


func _process(delta: float) -> void:
	time_since_shot += delta
	if fire_type == fire_types.semi_auto:
		if has_released and time_since_shot > fire_timer:
			can_shoot = true
	if Input.is_action_just_released("shoot"):
		has_released = true


func _on_shoot() -> void:
	ammo -= 1
	can_shoot = false
	has_released = false
	time_since_shot = 0
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	if fire_type == fire_types.auto:
		can_shoot = true
