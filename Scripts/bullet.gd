extends Node3D

var last_position: Vector3
var tracer_firepoint: Node3D
var bullet_stats: BulletStats
var gun_stats: GunStats
var tracer: PackedScene = preload("res://Scenes/Bullets/tracer.tscn")
var dust: PackedScene = preload("res://Scenes/Particles/dust.tscn")
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
		create_tracer()
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
	if collider is HealthComponent:
		var damage = bullet_stats.damage * (0.5 + min(0.5 * (gun_stats.condition / gun_stats.max_condition) / 0.75, 0.5))
		collider.damage(bullet_stats.damage, raycast.get_collision_point(), rotation)
		if !bullet_stats.is_hitscan:
			queue_free()
	elif collider is RigidBody3D:
		collider.apply_impulse(-global_transform.basis.z.normalized() * (bullet_stats.speed / 100))
	elif collider.is_in_group("ground"):
		var inst = dust.instantiate() 
		get_tree().current_scene.add_child(inst)
		inst.global_position = raycast.get_collision_point()
		inst.rotation.y = rotation.y
		inst.emitting = true
	# create hitmark
	if collider.get_parent() is CharacterBody3D:
		return
	var inst = bullet_stats.hitmarker.instantiate()
	collider.add_child(inst)
	inst.global_position = raycast.get_collision_point()
	inst.look_at(inst.global_position + raycast.get_collision_normal(), Vector3.FORWARD)
	if !bullet_stats.is_hitscan:
		queue_free()


func create_tracer():
	pass
	#var tracer_instance = Globals.create_particle(tracer, tracer_firepoint.global_position, tracer_firepoint)
	#var tracer_instance = tracer.instantiate()
	#get_tree().current_scene.add_child(tracer_instance)
	#tracer_instance.global_position = tracer_firepoint.global_position
	#if tracer_instance != null:
		#if raycast.is_colliding():
			#tracer_instance.end_point = raycast.get_collision_point()
		#else:
			#tracer_instance.end_point = tracer_firepoint.global_position + (-global_transform.basis.z.normalized() * 100)
		#tracer_instance.look_at.call_deferred(tracer_instance.end_point)
