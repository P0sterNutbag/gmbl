extends Node

@export var bullet_stats: BulletStats
@export var ammo_type: String
enum fire_types {semi_auto, auto}
@export var fire_type: fire_types
@export var fire_timer: float
var ammo: int
var can_shoot: bool = true
var shoot_timer: Timer


func _ready() -> void:
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 0.1
	shoot_timer.one_shot = true
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	add_child(shoot_timer)


func _process(delta: float) -> void:
	if Input.is_action_just_released("shoot"):
		if fire_type == fire_types.semi_auto:
			can_shoot = true


func _on_shoot() -> void:
	ammo -= 1
	can_shoot = false
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	if fire_type == fire_types.auto:
		can_shoot = true
