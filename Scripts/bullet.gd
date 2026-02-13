extends Node3D

var last_position: Vector3
var tracer_firepoint: Node3D
var creator: Node3D
var bullet_stats: BulletStats
var tracer: PackedScene = preload("res://Scenes/Bullets/tracer.tscn")
var dust: PackedScene = preload("res://Scenes/Effects/Particles/dust.tscn")
var blood_spatter: PackedScene = preload("res://Scenes/Effects/Decals/bloodspatter.tscn")
@onready var bullet_mesh = $MeshInstance3D
@onready var raycast = $RayCast3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	#raycast.set_collision_mask_value(bullet_stats.collision_mask, true)
	if bullet_stats.is_hitscan:
		raycast.target_position.z = -100
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit()
	if bullet_stats.is_hitscan:
		create_tracer()
		queue_free.call_deferred()


func _physics_process(delta: float) -> void:
	raycast.target_position = Vector3.FORWARD * bullet_stats.speed * delta
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit()
	global_translate(-global_transform.basis.z.normalized() * bullet_stats.speed * delta)
	#if bullet_stats.bullet_drop:
	global_translate(global_transform.basis.y.normalized() * -bullet_stats.drop_speed * delta)
	bullet_stats.drop_speed = move_toward(bullet_stats.drop_speed, bullet_stats.max_drop_speed, delta * 50)
	visible = true


func hit():
	# damage collider if enemy
	var collider = raycast.get_collider()
	if collider is PhysicalBone3D and collider.health_component == creator.health_component:#collider.owner == creator:
		return
	#var damage = bullet_stats.damage * (0.5 + min(0.5 * (gun_stats.condition / gun_stats.max_condition) / 0.75, 0.5))
	if collider is PhysicalBone3D:
		if collider.health_component:
			collider.health_component.damage(bullet_stats.damage * collider.damage_modifier, raycast.get_collision_point(), rotation, creator)
		var decal = blood_spatter.instantiate()
		decal.set_deferred("global_position", raycast.get_collision_point())
		collider.add_child(decal)
		#collider.get_parent().physical_bones_start_simulation([collider.bone_name])
		#collider.apply_impulse(rotation * 50, raycast.get_collision_point())
		#collider.turn_off_simulation()
	elif collider is HealthComponent:
		collider.damage(bullet_stats.damage, raycast.get_collision_point(), rotation, creator)
		if !bullet_stats.is_hitscan:
			queue_free()
	elif collider.get_parent() is Trap:
		collider.get_parent().trigger()
	else:
		if collider is RigidBody3D:
			collider.apply_impulse(-global_transform.basis.z.normalized() * (bullet_stats.speed / 100))
		var dust_inst = dust.instantiate() 
		get_tree().current_scene.add_child(dust_inst)
		dust_inst.global_position = raycast.get_collision_point()
		dust_inst.rotation.y = rotation.y
		dust_inst.emitting = true
	# create hitmark
	if collider.get_parent() is CharacterBody3D:
		return
	var inst = bullet_stats.hitmarker.instantiate()
	collider.add_child(inst)
	inst.global_position = raycast.get_collision_point()
	inst.look_at(inst.global_position + raycast.get_collision_normal(), Vector3.FORWARD)
	audio_stream_player_3d.play()
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


func _exit_tree() -> void:
	Globals.noise_controller.create_noise_event(global_position, self)
