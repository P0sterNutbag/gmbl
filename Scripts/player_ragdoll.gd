extends CharacterSetup

@onready var physical_bone_simulator: PhysicalBoneSimulator3D = $PersonAnimated/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var camera: Camera3D = $CameraAnchor/Camera3D
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var right_hand: Node3D = $PersonAnimated/Armature/Skeleton3D/RightHand/Node3D


func _ready() -> void:
	super._ready()
	animation_player.play("IdleAim")
	right_hand.process_mode = Node.PROCESS_MODE_DISABLED
	hide()


func _process(delta: float) -> void:
	if !visible:
		return
	camera_anchor.rotate(Vector3.UP, deg_to_rad(delta * 2))


func start_ragdoll(damage_position: Vector3, fall_direction: Vector3, gun: Gun) -> void:
	show()
	camera_anchor.rotation = Vector3.ZERO
	camera.current = true
	if gun:
		if right_hand.get_child_count() > 0:
			right_hand.get_child(0).queue_free()
		var gun_scene = load(gun.scene_file_path)
		var inst = gun_scene.instantiate()
		right_hand.add_child(inst)
	physical_bone_simulator.active = true
	physical_bone_simulator.physical_bones_start_simulation()
	var bones = physical_bone_simulator.get_children()
	bones.sort_custom(func(a, b): return a.global_position.distance_to(damage_position) < b.global_position.distance_to(damage_position))
	for i in bones.size():
		var bone = bones[i]
		bone.apply_impulse(-fall_direction * 5)
		if i > 3:
			continue
	print(fall_direction)
	Engine.time_scale = 0.35
	await get_tree().create_timer(1).timeout
	Engine.time_scale = 1.0


func reset() -> void:
	hide()
	physical_bone_simulator.active = false
	physical_bone_simulator.physical_bones_stop_simulation()
	animation_player.play("IdleAim")
	Engine.time_scale = 1.0


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	
