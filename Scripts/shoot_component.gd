extends Node

@export var bullet_stats: BulletStats
@export var firepoint: Node3D
@export var tracer_firepoint: Node3D
var time_shooting := 0.0
var spread := 1.0
var gun_stats: GunStats
var spread_curve := (preload("res://Resources/Curves/bullet_spread.tres"))


func _process(delta: float) -> void:
	time_shooting -= delta * 2
	time_shooting = clamp(time_shooting, 0, 1)
	spread = lerp(1, 2, spread_curve.sample(time_shooting))


func _on_shoot(is_ads: bool = false, movement_speed = Vector3.ZERO) -> void:
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
		inst.gun_stats = gun_stats
		inst.tracer_firepoint = tracer_firepoint
		get_tree().current_scene.add_child(inst)
