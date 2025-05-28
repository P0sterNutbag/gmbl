extends Node3D

var last_position: Vector3
var tracer_firepoint: Node3D
var bullet_stats: BulletStats
var tracer: PackedScene = preload("res://Scenes/Bullets/tracer.tscn")
@onready var bullet_mesh = $MeshInstance3D
@onready var raycast = $RayCast3D


func _ready() -> void:
	raycast.set_collision_mask_value(bullet_stats.collision_mask, true)
	if bullet_stats.is_hitscan:
		raycast.target_position.z = -100
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit()
	if bullet_stats.is_hitscan:
		var inst = tracer.instantiate()
		get_tree().current_scene.add_child(inst)
		inst.global_transform = tracer_firepoint.global_transform
		inst.global_translate(-global_transform.basis.z.normalized() * 1)
		inst.end_point = raycast.get_collision_point()
		queue_free.call_deferred()


func _physics_process(delta: float) -> void:
	last_position = global_position
	bullet_mesh.visible = true
	global_translate(-global_transform.basis.z.normalized() * bullet_stats.speed * delta)
	if bullet_stats.bullet_drop:
		global_translate(global_transform.basis.y.normalized() * -bullet_stats.drop_speed * delta)
		bullet_stats.drop_speed = move_toward(bullet_stats.drop_speed, bullet_stats.max_drop_speed, delta * 50)
	var last_velocity = global_position - last_position
	var max_speed = max(abs(last_velocity.x), abs(last_velocity.y), abs(last_velocity.z))
	raycast.target_position = Vector3.FORWARD * max_speed * 2
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit()


func hit():
	# damage collider if enemy
	var collider = raycast.get_collider()
	var health_comp = collider.get_parent()
	if collider is HealthComponent:
		collider.damage(bullet_stats.damage, raycast.get_collision_point(), rotation)
		print(rotation)
		if !bullet_stats.is_hitscan:
			queue_free()
		return
	# create hitmark
	var inst = bullet_stats.hitmarker.instantiate()
	get_tree().current_scene.add_child(inst)
	inst.global_position = raycast.get_collision_point()
	if !bullet_stats.is_hitscan:
		queue_free()
