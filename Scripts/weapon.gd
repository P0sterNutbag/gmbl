extends Node3D
class_name Weapon

@export var uses_input: bool
enum fire_types {semi_auto, auto, pump}
@export var fire_type: fire_types
var time_since_use: float
var can_use: bool = true
var has_released: bool = true
var anim_player: AnimationPlayer
var cooldown_timer: Timer


func _ready() -> void:
	cooldown_timer = get_node_or_null("Cooldown")
	anim_player = get_node_or_null("AnimationPlayer")


func _process(delta: float) -> void:
	if !uses_input:
		return
	time_since_use += delta
	if fire_type == fire_types.semi_auto:
		if has_released and time_since_use > cooldown_timer.wait_time:
			can_use = true
	if Input.is_action_just_released("shoot"):
		has_released = true	


func use() -> bool:
	if !can_use:
		return false
	if cooldown_timer:
		cooldown_timer.start()
	return true


func _cooldown_timeout() -> void:
	if fire_type == fire_types.auto or !uses_input:
		can_use = true
