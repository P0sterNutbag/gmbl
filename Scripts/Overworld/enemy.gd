extends CharacterBody3D

enum guns {shotgun, ak47, sniper, pistol}
@export var gun_index: guns
var walk_speed := 2
var path_index := 0
var guns_dict: Dictionary = {
	0 : [preload("res://Scenes/Guns/shotgun.tscn"), preload("res://Scenes/Items/Guns/shotgun.tscn")],
	1 : [preload("res://Scenes/Guns/ak47.tscn"), preload("res://Scenes/Items/Guns/assault_rifle.tscn")],
	2 : [preload("res://Scenes/Guns/sniper.tscn"), preload("res://Scenes/Items/Guns/sniper_rifle.tscn")],
	3 : [preload("res://Scenes/Guns/pistol.tscn"), preload("res://Scenes/Items/Guns/pistol.tscn")],
}
@onready var detection: Node3D = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var gun_holder: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D


func _ready() -> void:
	detection.targets.append(Globals.player)
	var gun = guns_dict[gun_index][0].instantiate()
	gun_holder.add_child(gun)


func _process(delta: float) -> void:
	#if detection.get_visible_target():
		#navigation_agent.set_target_position(Globals.player.global_position)
	if get_parent() is Path3D:
		var next_point = get_parent().global_position + get_parent().curve.get_point_position(path_index)
		if navigation_agent.target_position != next_point:
			navigation_agent.set_target_position(next_point)
	follow_path()
	
	# animate
	if velocity != Vector3.ZERO:
		anim_player.play("Walk")
	else:
		anim_player.play("Idle")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path(speed: float = walk_speed):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	next_path_position.y = global_position.y
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	navigation_agent.set_velocity(velocity)
	velocity = new_velocity
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	if pos == global_position:
		return
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func die():
	$Area3D.queue_free()
	$CollisionShape3D.disabled = true
	set_process(false)
	anim_player.play("Die")
	anim_player.seek(4.4)
	await tree_entered
	await get_tree().create_timer(10).timeout
	queue_free()


func _on_navigation_agent_3d_navigation_finished() -> void:
	path_index = wrap(path_index + 1, 0, get_parent().curve.point_count)
	velocity = Vector3.ZERO
