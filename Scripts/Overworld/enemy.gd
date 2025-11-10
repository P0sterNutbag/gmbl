extends CharacterBody3D

enum guns {shotgun, ak47, sniper, pistol}
@export var gun_index: guns
var walk_speed := 2
var path_index := 0
var max_enemies := 6
var min_enemies := 3
var destination: Location
var guns_dict: Dictionary = {
	0 : [preload("res://Scenes/Guns/shotgun.tscn"), preload("res://Scenes/Items/Guns/shotgun.tscn")],
	1 : [preload("res://Scenes/Guns/ak47.tscn"), preload("res://Scenes/Items/Guns/ak47.tscn")],
	2 : [preload("res://Scenes/Guns/sniper.tscn"), preload("res://Scenes/Items/Guns/sniper_rifle.tscn")],
	3 : [preload("res://Scenes/Guns/pistol.tscn"), preload("res://Scenes/Items/Guns/pistol.tscn")],
}
@onready var detection: Node3D = $Detection
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $EnemyModel/PersonAnimated/AnimationPlayer
@onready var gun_holder: Node3D = $EnemyModel/PersonAnimated/Armature/Skeleton3D/RightHand/Node3D
@onready var location: Location = $Location
@onready var enemy_model: Node3D = $EnemyModel


func _ready() -> void:
	detection.targets.append(Globals.player)
	var gun = guns_dict[gun_index][0].instantiate()
	gun_holder.add_child(gun)
	location.location_data.population = randi_range(min_enemies, max_enemies)
	location.spawn_player_random = true


func _process(_delta: float) -> void:
	# animate
	if velocity != Vector3.ZERO:
		anim_player.play("Walk")
	else:
		anim_player.play("Idle")


func _physics_process(delta: float) -> void:
	# move towards destination
	if navigation_agent.target_position != Vector3.ZERO:
		follow_path()
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func follow_path(speed: float = walk_speed):
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * speed
	look_at_position(next_path_position)


func look_at_position(pos: Vector3):
	if pos == global_position:
		return
	var target_pos = pos
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)


func die():
	set_collision_layer_value(1, false)
	location.monitoring = false
	location.monitorable = false
	velocity = Vector3.ZERO
	set_process(false)
	anim_player.play("Die")
	anim_player.seek(4.4)
	await tree_entered
	await get_tree().create_timer(10).timeout
	queue_free()


func _on_navigation_agent_3d_navigation_finished() -> void:
	destination.location_data.change_population(location.location_data.population)
	queue_free()
