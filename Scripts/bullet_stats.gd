extends Resource
class_name BulletStats

@export var speed = 250.0
@export var max_drop_speed = 3.0
@export var min_drop_speed = 0.0
@export var drop_speed = 0.0
@export var damage = 1.0
@export var is_hitscan: bool = true
@export var bullet_drop: bool = true
@export var collision_mask := 3
@export var hitmarker = preload("res://Scenes/hitmarker.tscn")
