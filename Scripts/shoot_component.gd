extends Node

@export var bullet = preload("res://Scenes/bullet.tscn")
@export var bullet_stats: BulletStats
@export var firepoint: Node3D


func _on_shoot() -> void:
	var inst = bullet.instantiate()
	inst.global_transform = firepoint.global_transform
	inst.bullet_stats = bullet_stats
	get_tree().current_scene.add_child(inst)
