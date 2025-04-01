extends Node

@export var bullet = preload("res://Scenes/bullet.tscn")
@export var bullet_stats: BulletStats
@export var firepoint: Node3D


func _on_shoot() -> void:
	var inst = bullet.instantiate()
	inst.global_transform = firepoint.global_transform
	var h_angle_variance = randf_range(-bullet_stats.h_angle_variance, bullet_stats.h_angle_variance)
	inst.rotate_y(deg_to_rad(h_angle_variance))
	var v_angle_variance = randf_range(-bullet_stats.v_angle_variance, bullet_stats.v_angle_variance)
	inst.rotate_x(deg_to_rad(v_angle_variance))
	inst.bullet_stats = bullet_stats
	get_tree().current_scene.add_child(inst)
