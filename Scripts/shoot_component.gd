extends Node

@export var bullet_stats: BulletStats
@export var firepoint: Node3D
@export var tracer_firepoint: Node3D


func _on_shoot(is_ads: bool = false) -> void:
	for i in bullet_stats.amount:
		var inst = bullet_stats.bullet_scene.instantiate()
		inst.global_transform = firepoint.global_transform
		var variance = Vector2(bullet_stats.h_angle_variance_hip, bullet_stats.v_angle_variance_hip)
		if is_ads:
			variance = Vector2(bullet_stats.h_angle_variance_ads, bullet_stats.v_angle_variance_ads)
		var h_angle_variance = randf_range(-variance.x, variance.x)
		inst.rotate_y(deg_to_rad(h_angle_variance))
		var v_angle_variance = randf_range(-variance.y, variance.y)
		inst.rotate_x(deg_to_rad(v_angle_variance))
		inst.bullet_stats = bullet_stats
		inst.tracer_firepoint = tracer_firepoint
		get_tree().current_scene.add_child(inst)
