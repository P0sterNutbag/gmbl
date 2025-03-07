extends Node3D

var speed = 500.0
var max_drop_speed = 200.0
var min_drop_speed = 10.0
var drop_speed = 0.0
var damage = 1.0
var last_position: Vector3
var hitmarker = preload("res://Scenes/hitmarker.tscn")
@onready var bullet_mesh = $MeshInstance3D
@onready var raycast = $RayCast3D


func _ready() -> void:
	bullet_mesh.visible = false
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit()


func _physics_process(delta: float) -> void:
	last_position = global_position
	bullet_mesh.visible = true
	global_translate(global_transform.basis.z.normalized() * speed * delta)
	global_translate(global_transform.basis.y.normalized() * -drop_speed * delta)
	drop_speed = move_toward(drop_speed, max_drop_speed, delta * 50)
	var last_velocity = global_position - last_position
	var max_speed = max(abs(last_velocity.x), abs(last_velocity.y), abs(last_velocity.z))
	raycast.target_position = Vector3.BACK * max_speed * 2
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit()


func hit():
	# damage collider if enemy
	var collider = raycast.get_collider()
	var health_comp = collider.get_parent()
	if collider is HealthComponent:
		collider.damage(damage)
		queue_free()
		return
	# create hitmark
	var inst = hitmarker.instantiate()
	collider.add_child(inst)
	inst.global_position = raycast.get_collision_point()
	inst.set_rotation_to_normal(raycast.get_collision_normal())
	queue_free()
