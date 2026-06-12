extends Resource
class_name BulletStats

@export var bullet_scene = preload("res://Scenes/Bullets/bullet.tscn")
@export var amount = 1
@export var speed = 250.0
@export var damage = 1.0
@export var noise_radius = 30.0
@export var is_hitscan: bool = true
@export var bullet_drop: bool = false
@export var collision_mask := 3
@export var hitmarker = preload("res://Scenes/Effects/Decals/hitmarker.tscn")
